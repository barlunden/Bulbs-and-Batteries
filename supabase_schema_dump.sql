-- =============================================================================
-- SUPABASE SCHEMA DUMP
-- Køyr denne i Supabase Dashboard → SQL Editor
-- Kopier HEILE resultatet og lim inn til meg
-- =============================================================================

-- 1. ALLE TABELLAR MED KOLONNAR OG DATATYPAR
SELECT 
  'TABLE: ' || table_name as info,
  column_name,
  data_type,
  character_maximum_length,
  column_default,
  is_nullable,
  ordinal_position
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name IN ('profiles', 'households', 'household_members', 'items', 'stock', 'general_notes')
ORDER BY table_name, ordinal_position;

-- 2. PRIMARY KEYS
SELECT 
  'PRIMARY KEY: ' || tc.table_name as info,
  kcu.column_name,
  tc.constraint_name
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu 
  ON tc.constraint_name = kcu.constraint_name
WHERE tc.table_schema = 'public'
  AND tc.constraint_type = 'PRIMARY KEY'
  AND tc.table_name IN ('profiles', 'households', 'household_members', 'items', 'stock', 'general_notes')
ORDER BY tc.table_name;

-- 3. FOREIGN KEYS
SELECT 
  'FOREIGN KEY: ' || tc.table_name as info,
  kcu.column_name,
  ccu.table_name AS foreign_table_name,
  ccu.column_name AS foreign_column_name,
  tc.constraint_name
FROM information_schema.table_constraints AS tc 
JOIN information_schema.key_column_usage AS kcu
  ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage AS ccu
  ON ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY'
  AND tc.table_schema = 'public'
  AND tc.table_name IN ('profiles', 'households', 'household_members', 'items', 'stock', 'general_notes')
ORDER BY tc.table_name;

-- 4. CHECK CONSTRAINTS
SELECT 
  'CHECK: ' || tc.table_name as info,
  tc.constraint_name,
  cc.check_clause
FROM information_schema.table_constraints tc
JOIN information_schema.check_constraints cc
  ON tc.constraint_name = cc.constraint_name
WHERE tc.table_schema = 'public'
  AND tc.constraint_type = 'CHECK'
  AND tc.table_name IN ('profiles', 'households', 'household_members', 'items', 'stock', 'general_notes')
ORDER BY tc.table_name;

-- 5. INDEXES
SELECT 
  'INDEX: ' || tablename as info,
  indexname,
  indexdef
FROM pg_indexes
WHERE schemaname = 'public'
  AND tablename IN ('profiles', 'households', 'household_members', 'items', 'stock', 'general_notes')
ORDER BY tablename, indexname;

-- 6. RLS POLICIES
SELECT 
  'POLICY: ' || tablename as info,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename IN ('profiles', 'households', 'household_members', 'items', 'stock', 'general_notes')
ORDER BY tablename, policyname;

-- 7. RLS STATUS
SELECT 
  'RLS: ' || tablename as info,
  rowsecurity
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename IN ('profiles', 'households', 'household_members', 'items', 'stock', 'general_notes')
ORDER BY tablename;

-- 8. TRIGGERS OG FUNCTIONS
SELECT 
  'TRIGGER: ' || event_object_table as info,
  trigger_name,
  event_manipulation,
  action_statement,
  action_timing
FROM information_schema.triggers
WHERE trigger_schema = 'public'
  AND event_object_table IN ('profiles', 'households', 'household_members', 'items', 'stock', 'general_notes')
ORDER BY event_object_table, trigger_name;
