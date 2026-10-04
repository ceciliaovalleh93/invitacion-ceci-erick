# Boda Ceci & Erick — sistema RSVP (versión inicial)

Este proyecto es una base funcional de invitación y confirmación web. Incluye una vista pública, códigos para invitados previamente registrados, y un panel administrativo con gráficas y exportación CSV.

## Importante antes de compartir

- Los enlaces personalizados contienen un código único de invitación. Compártelos únicamente con la familia correspondiente.
- El enlace general no permite registrarse libremente: cada persona necesita un código que tú hayas generado al registrar a sus invitados.
- El código funciona como llave de acceso a la invitación. No lo publiques en redes.
- Esta es una primera versión. Antes de usarla para la boda, conviene probarla con invitaciones ficticias y revisar el flujo de cambios de respuesta.

## 1. Requisitos

Instala Node.js (versión LTS) en tu computadora. Crea una cuenta gratuita en Supabase y otra en Vercel.

## 2. Crear la base de datos

1. En Supabase crea un proyecto nuevo.
2. Abre **SQL Editor** y pega el contenido completo de `supabase.sql`; ejecútalo.
3. En **Authentication > Users**, crea tu usuario administrador con tu correo y una contraseña segura. Desactiva el registro público de usuarios (Sign-ups) en la configuración de Authentication; solo tú debes tener cuenta administrativa.
4. En **Project Settings > API**, copia Project URL y la clave `anon`/publishable.

## 3. Conectar la aplicación

1. En la carpeta del proyecto, duplica `.env.example` y nombra la copia `.env`.
2. Completa `VITE_SUPABASE_URL` y `VITE_SUPABASE_ANON_KEY` con los valores de tu proyecto.
3. Abre una terminal dentro de esta carpeta y ejecuta:

```bash
npm install
npm run dev
```

4. Abre la dirección local que muestre Vite (normalmente `http://localhost:5173`). La página de invitación abre por defecto; el panel está en **Administración**.

## 4. Registrar invitados

En esta primera versión, agrega invitados desde **Supabase > Table Editor > guests > Insert row**:

- `family_name`: nombre de familia o titular (ej. Familia García).
- `guest_names`: nombres de las personas invitadas.
- `max_seats`: cantidad máxima de pases.
- `invite_code`: puedes dejarlo vacío para que se genere automáticamente.
- `status`: `pending`.
- `attending_count`: dejar vacío.

Guarda cada registro. El panel muestra el código/enlace individual en la tabla de administración. Para el enlace general, comparte la URL principal y entrega a cada invitado su código.

## 5. Publicar para que funcione en celulares

1. Sube la carpeta del proyecto a un repositorio privado o público de GitHub (no subas el archivo `.env`).
2. En Vercel importa el repositorio y configura las variables `VITE_SUPABASE_URL` y `VITE_SUPABASE_ANON_KEY` en **Environment Variables**.
3. Publica el proyecto. Vercel te dará una URL HTTPS para compartir.
4. Prueba tanto el enlace general con un código válido como varios enlaces personalizados desde un celular.

## Alcance actual

- Confirmación y declinación con límite de pases.
- Los registros públicos no pueden consultar directamente la tabla de invitados.
- Dashboard con conteos, gráficas, búsqueda y exportación CSV.
- Administración de invitados desde Supabase Table Editor; la edición directa dentro del panel aún no está implementada.
- El panel requiere iniciar sesión con el usuario administrador de Supabase.

## Seguridad y privacidad

No uses la clave `service_role` en el frontend. La aplicación solo debe llevar la clave pública `anon`/publishable. Mantén el acceso administrativo protegido y no compartas códigos de invitación públicamente. Para una versión final se recomienda agregar límites de intentos, expiración o rotación de códigos, y una pantalla de gestión de invitados dentro del dashboard.
