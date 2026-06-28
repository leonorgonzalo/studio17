// ============================================
// STUDIO17 — Lógica de disponibilidad
// ============================================

const BREAK_MINUTES = 5; // pausa entre citas

function timeToMinutes(timeStr) {
  const [h, m] = timeStr.split(':').map(Number);
  return h * 60 + m;
}

function minutesToTime(minutes) {
  const h = Math.floor(minutes / 60);
  const m = minutes % 60;
  return `${String(h).padStart(2,'0')}:${String(m).padStart(2,'0')}`;
}

function parseLocalDate(dateStr) {
  // dateStr: 'YYYY-MM-DD'
  const [y, m, d] = dateStr.split('-').map(Number);
  return new Date(y, m - 1, d);
}

function toLocalDateStr(date) {
  const y = date.getFullYear();
  const m = String(date.getMonth() + 1).padStart(2, '0');
  const d = String(date.getDate()).padStart(2, '0');
  return `${y}-${m}-${d}`;
}

// day_of_week en DB: 0=Lun, 1=Mar... 5=Sab, 6=Dom
// getDay() JS: 0=Dom, 1=Lun... 6=Sab
function jsDayToDbDay(jsDay) {
  return jsDay === 0 ? 6 : jsDay - 1;
}

async function getAvailableSlots(staffId, serviceId, dateStr) {
  const date = parseLocalDate(dateStr);
  const dbDay = jsDayToDbDay(date.getDay());

  // 1. Horario de la empleada ese día
  const schedules = await supabaseRequest(
    `studio17_schedules?staff_id=eq.${staffId}&day_of_week=eq.${dbDay}&select=*`
  );
  if (!schedules.length) return [];

  // 2. Duración del servicio
  const services = await supabaseRequest(
    `studio17_services?id=eq.${serviceId}&select=duration_minutes`
  );
  if (!services.length) return [];
  const duration = services[0].duration_minutes;

  // 3. Reservas ese día
  const dayStart = `${dateStr}T00:00:00`;
  const dayEnd = `${dateStr}T23:59:59`;
  const bookings = await supabaseRequest(
    `studio17_bookings?staff_id=eq.${staffId}&starts_at=gte.${dayStart}&starts_at=lte.${dayEnd}&status=eq.confirmed&select=starts_at,ends_at`
  );

  // 4. Bloqueos ese día
  const blocked = await supabaseRequest(
    `studio17_blocked_slots?staff_id=eq.${staffId}&starts_at=gte.${dayStart}&starts_at=lte.${dayEnd}&select=starts_at,ends_at`
  );

  // 5. Convertir ocupados a rangos de minutos
  function toMinRange(starts, ends) {
    const s = new Date(starts);
    const e = new Date(ends);
    return {
      start: s.getHours() * 60 + s.getMinutes(),
      end: e.getHours() * 60 + e.getMinutes()
    };
  }

  const busyRanges = [
    ...bookings.map(b => {
      const r = toMinRange(b.starts_at, b.ends_at);
      // añadir pausa después de cada cita
      return { start: r.start, end: r.end + BREAK_MINUTES };
    }),
    ...blocked.map(b => toMinRange(b.starts_at, b.ends_at))
  ];

  // 6. Generar slots cada 15 minutos dentro del horario
  const slots = [];
  const now = new Date();
  const isToday = dateStr === toLocalDateStr(now);
  const nowMinutes = now.getHours() * 60 + now.getMinutes() + 30; // +30min buffer

  for (const sched of schedules) {
    const start = timeToMinutes(sched.start_time);
    const end = timeToMinutes(sched.end_time);

    for (let t = start; t + duration <= end; t += 15) {
      // Skip slots pasados si es hoy
      if (isToday && t < nowMinutes) continue;

      const slotEnd = t + duration;
      const overlaps = busyRanges.some(r => t < r.end && slotEnd > r.start);
      if (!overlaps) {
        slots.push(minutesToTime(t));
      }
    }
  }

  return slots;
}

// Formatear fecha bonita en español
function formatDateEs(dateStr) {
  const date = parseLocalDate(dateStr);
  return date.toLocaleDateString('es-ES', {
    weekday: 'long',
    day: 'numeric',
    month: 'long',
    year: 'numeric'
  });
}

function formatDateShort(dateStr) {
  const date = parseLocalDate(dateStr);
  return date.toLocaleDateString('es-ES', {
    weekday: 'short',
    day: 'numeric',
    month: 'short'
  });
}

function formatDuration(minutes) {
  const h = Math.floor(minutes / 60);
  const m = minutes % 60;
  if (h === 0) return `${m} min`;
  if (m === 0) return `${h}h`;
  return `${h}h ${m}min`;
}

function formatPrice(price) {
  return Number(price).toFixed(2).replace('.', ',') + ' €';
}
