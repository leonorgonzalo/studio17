-- ============================================
-- STUDIO17 - Ejecuta esto en Supabase SQL Editor
-- ============================================

-- Empleadas
CREATE TABLE IF NOT EXISTS studio17_staff (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Horarios por empleada (por día de la semana)
CREATE TABLE IF NOT EXISTS studio17_schedules (
  id SERIAL PRIMARY KEY,
  staff_id INTEGER REFERENCES studio17_staff(id) ON DELETE CASCADE,
  day_of_week INTEGER NOT NULL,
  start_time TIME NOT NULL,
  end_time TIME NOT NULL
);

-- Categorías de servicios
CREATE TABLE IF NOT EXISTS studio17_categories (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  sort_order INTEGER DEFAULT 0
);

-- Servicios
CREATE TABLE IF NOT EXISTS studio17_services (
  id SERIAL PRIMARY KEY,
  category_id INTEGER REFERENCES studio17_categories(id) ON DELETE SET NULL,
  name TEXT NOT NULL,
  duration_minutes INTEGER NOT NULL,
  price NUMERIC(8,2) NOT NULL,
  active BOOLEAN DEFAULT true,
  sort_order INTEGER DEFAULT 0
);

-- Bloqueos manuales
CREATE TABLE IF NOT EXISTS studio17_blocked_slots (
  id SERIAL PRIMARY KEY,
  staff_id INTEGER REFERENCES studio17_staff(id) ON DELETE CASCADE,
  starts_at TIMESTAMPTZ NOT NULL,
  ends_at TIMESTAMPTZ NOT NULL,
  reason TEXT
);

-- Reservas
CREATE TABLE IF NOT EXISTS studio17_bookings (
  id SERIAL PRIMARY KEY,
  staff_id INTEGER REFERENCES studio17_staff(id),
  service_id INTEGER REFERENCES studio17_services(id),
  client_name TEXT NOT NULL,
  client_phone TEXT NOT NULL,
  starts_at TIMESTAMPTZ NOT NULL,
  ends_at TIMESTAMPTZ NOT NULL,
  status TEXT DEFAULT 'confirmed',
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- DATOS INICIALES
-- ============================================

INSERT INTO studio17_staff (name) VALUES ('Leonor');

INSERT INTO studio17_schedules (staff_id, day_of_week, start_time, end_time) VALUES
(1, 0, '10:00'::time, '19:00'::time),
(1, 1, '10:00'::time, '19:00'::time),
(1, 2, '10:00'::time, '19:00'::time),
(1, 3, '10:00'::time, '19:00'::time),
(1, 4, '10:00'::time, '19:00'::time),
(1, 5, '10:00'::time, '14:00'::time);

INSERT INTO studio17_categories (name, sort_order) VALUES
('Packs', 1),
('Semipermanente con retirada', 2),
('Semipermanente sin retirada', 3),
('Semipermanente + Capa refuerzo', 4),
('Acrílico', 5),
('Acrygel', 6),
('Retiradas', 7),
('Tratamiento Spa', 8),
('Esmaltado clásico', 9),
('Manicuras sin esmaltado', 10),
('Depilación con hilo', 11),
('Tratamientos cejas', 12),
('Tratamientos pestañas', 13),
('Otros', 14);

INSERT INTO studio17_services (category_id, name, duration_minutes, price) VALUES
(1, 'Manicura semi con ref gel + Diseño cejas y labio', 65, 40.95),
(1, 'Manicura semi + ref gel + Diseño cejas', 65, 36.95),
(1, 'Manicura semi + Pack diseño cejas + labio', 55, 35.95),
(1, 'Manicura semi + Diseño de cejas', 55, 31.95),
(1, 'Pack manipedi semi + Diseño cejas', 90, 49.00),
(1, 'Pack manipedi semi + Diseño cejas y labio', 90, 53.00),
(2, 'Manicura semipermanente básica', 40, 18.95),
(2, 'Pedicura semipermanente', 40, 22.95),
(2, 'Pack manicura y pedicura semipermanente', 75, 36.00),
(3, 'Manicura semipermanente básica', 30, 18.95),
(3, 'Pedicura semipermanente', 30, 22.95),
(3, 'Pack manicura y pedicura semipermanente', 60, 36.00),
(4, 'Manicura semi básica con refuerzo de gel (con retirada)', 50, 23.95),
(4, 'Manicura semi básica con refuerzo de gel (sin retirada)', 45, 23.95),
(4, 'Manicura semi con refuerzo de acrilico', 65, 27.95),
(4, 'Manicura semi básica con refuerzo de acrygel', 65, 27.95),
(4, 'Manicura Rusa + Semipermanente', 60, 32.00),
(5, 'Primera puesta', 85, 39.00),
(5, 'Retirada acrilico (otro salon) + Primera puesta', 120, 51.00),
(5, 'Relleno básico', 75, 34.00),
(5, 'Primera puesta XL', 105, 44.00),
(5, 'Primera puesta XXL', 120, 49.00),
(5, 'Relleno XL', 90, 39.00),
(5, 'Relleno XXL', 105, 44.00),
(5, 'Unas mordidas', 75, 38.00),
(5, 'Unas guitarrista (4 unas)', 35, 14.00),
(5, 'Unas guitarrista (3 unas)', 20, 10.50),
(6, 'Primera puesta', 80, 39.00),
(6, 'Primera puesta XL', 105, 44.00),
(6, 'Primera puesta XXL', 120, 49.00),
(6, 'Relleno básico', 75, 34.00),
(6, 'Relleno básico XL', 90, 39.00),
(6, 'Relleno básico XXL', 105, 44.00),
(7, 'Retirada acrilico/acrygel + Manicura', 30, 15.00),
(7, 'Retirada semi manos + manicura sin esmalte', 20, 9.50),
(7, 'Retirada semi pies + pedicura sin esmalte', 20, 9.50),
(8, 'Manicura semipermanente Spa', 50, 26.95),
(8, 'Pedicura semipermanente Spa', 75, 35.95),
(8, 'Manicura y pedicura semipermanente Spa', 120, 54.00),
(8, 'Manicura clasica Spa', 50, 22.95),
(8, 'Manicura rusa semipermanente Spa', 90, 39.00),
(8, 'Pedicura clasica Spa', 60, 31.95),
(8, 'Manicura y pedicura clasica Spa', 80, 43.00),
(9, 'Manicura clasica', 40, 14.95),
(9, 'Pedicura clasica', 40, 18.95),
(9, 'Pack manicura y pedicura clasica', 60, 29.50),
(10, 'Manicura sin esmalte', 15, 9.50),
(10, 'Manicura masculina sin esmalte', 20, 10.00),
(10, 'Pedicura sin esmalte', 15, 9.50),
(11, 'Diseno cejas', 15, 13.00),
(11, 'Pack diseno cejas + labio superior', 15, 17.00),
(11, 'Pack cejas + mejillas', 15, 13.50),
(11, 'Labio superior', 5, 5.50),
(11, 'Entrecejo', 5, 3.00),
(11, 'Mejillas', 5, 3.00),
(11, 'Barbilla', 5, 5.00),
(11, 'Menton', 10, 6.00),
(11, 'Patillas', 10, 6.00),
(11, 'Rostro completo', 35, 30.00),
(12, 'Laminado de cejas', 30, 35.00),
(12, 'Pack diseno + laminado de cejas', 30, 41.00),
(12, 'Tinte de cejas', 20, 20.00),
(12, 'Pack diseno cejas con hilo + tinte', 30, 26.00),
(12, 'Pack laminado + tinte de cejas', 45, 43.00),
(12, 'Pack laminado + diseno + tinte', 55, 56.00),
(12, 'Laminado + diseno + lifting + tinte pestanas', 90, 76.00),
(12, 'Laminado cejas + Lifting + Tinte pestanas', 90, 68.00),
(13, 'Lifting de pestanas', 60, 35.00),
(13, 'Tinte de pestanas', 25, 15.00),
(13, 'Pack Lifting + Tinte', 75, 40.00),
(13, 'Pack Lifting + Tinte + Laminado cejas', 90, 68.00),
(14, 'Arreglo una acrilica', 15, 3.50),
(14, 'Arreglo una semi', 10, 2.50),
(14, 'Cuticulas', 10, 2.00);

-- ============================================
-- SEGURIDAD (RLS)
-- ============================================

ALTER TABLE studio17_staff ENABLE ROW LEVEL SECURITY;
ALTER TABLE studio17_schedules ENABLE ROW LEVEL SECURITY;
ALTER TABLE studio17_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE studio17_services ENABLE ROW LEVEL SECURITY;
ALTER TABLE studio17_blocked_slots ENABLE ROW LEVEL SECURITY;
ALTER TABLE studio17_bookings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "public read staff" ON studio17_staff FOR SELECT USING (true);
CREATE POLICY "public read schedules" ON studio17_schedules FOR SELECT USING (true);
CREATE POLICY "public read categories" ON studio17_categories FOR SELECT USING (true);
CREATE POLICY "public read services" ON studio17_services FOR SELECT USING (true);
CREATE POLICY "public read bookings" ON studio17_bookings FOR SELECT USING (true);
CREATE POLICY "public insert bookings" ON studio17_bookings FOR INSERT WITH CHECK (true);
CREATE POLICY "public read blocked" ON studio17_blocked_slots FOR SELECT USING (true);

CREATE POLICY "admin all staff" ON studio17_staff FOR ALL USING (true);
CREATE POLICY "admin all schedules" ON studio17_schedules FOR ALL USING (true);
CREATE POLICY "admin all categories" ON studio17_categories FOR ALL USING (true);
CREATE POLICY "admin all services" ON studio17_services FOR ALL USING (true);
CREATE POLICY "admin all bookings" ON studio17_bookings FOR ALL USING (true);
CREATE POLICY "admin all blocked" ON studio17_blocked_slots FOR ALL USING (true);
