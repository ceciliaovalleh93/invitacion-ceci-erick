-- Esquema inicial para Ceci & Erick. Ejecuta todo en Supabase > SQL Editor.
create extension if not exists pgcrypto;
create table if not exists public.guests (
 id uuid primary key default gen_random_uuid(),
 family_name text not null,
 guest_names text not null,
 max_seats integer not null check (max_seats between 1 and 20),
 invite_code text not null unique default upper(encode(gen_random_bytes(5),'hex')),
 status text not null default 'pending' check (status in ('pending','confirmed','declined')),
 attending_count integer,
 created_at timestamptz not null default now(),
 updated_at timestamptz not null default now(),
 constraint valid_attendance check (attending_count is null or (attending_count between 0 and max_seats))
);
alter table public.guests enable row level security;
-- Solo administradores autenticados pueden consultar o modificar la lista.
create policy "admin read guests" on public.guests for select to authenticated using (true);
create policy "admin insert guests" on public.guests for insert to authenticated with check (true);
create policy "admin update guests" on public.guests for update to authenticated using (true) with check (true);
create policy "admin delete guests" on public.guests for delete to authenticated using (true);

-- El invitado no puede leer la tabla directamente. Estas funciones exponen solo
-- los datos mínimos para el código válido y validan el número de pases.
create or replace function public.find_guest_by_code(p_code text)
returns table(family_name text, guest_names text, max_seats integer, status text, attending_count integer)
language sql security definer set search_path = public as $$
 select g.family_name,g.guest_names,g.max_seats,g.status,g.attending_count
 from public.guests g where upper(g.invite_code)=upper(trim(p_code)) limit 1;
$$;
revoke all on function public.find_guest_by_code(text) from public;
grant execute on function public.find_guest_by_code(text) to anon, authenticated;

create or replace function public.submit_rsvp(p_code text,p_attending boolean,p_count integer)
returns json language plpgsql security definer set search_path = public as $$
declare g public.guests%rowtype;
begin
 select * into g from public.guests where upper(invite_code)=upper(trim(p_code)) for update;
 if not found then raise exception 'Código de invitación no válido.'; end if;
 if p_attending and (p_count is null or p_count < 1 or p_count > g.max_seats) then
   raise exception 'La cantidad de asistentes supera los pases asignados.';
 end if;
 update public.guests set status=case when p_attending then 'confirmed' else 'declined' end,
 attending_count=case when p_attending then p_count else 0 end, updated_at=now() where id=g.id;
 return json_build_object('message',case when p_attending then '¡Gracias! Tu asistencia quedó confirmada.' else 'Gracias por avisarnos. Lamentamos que no puedas acompañarnos.' end);
end; $$;
revoke all on function public.submit_rsvp(text,boolean,integer) from public;
grant execute on function public.submit_rsvp(text,boolean,integer) to anon, authenticated;
