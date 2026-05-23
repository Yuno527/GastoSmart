# Supabase – GastoSmart (integración completa)

## Tablas y dónde se usan en la app

| Tabla | Pantalla / flujo |
|-------|------------------|
| `cuentas` | Login, registro, admin usuarios, **saldo_actual** en perfil e inicio |
| `movimientos` | Home, agregar movimiento, historial, reportes |
| `categorias` | Admin categorías, selector de gastos |
| `presupuestos` | Perfil → presupuesto mensual |
| `metas_ahorro` | Perfil → meta de ahorro (+ progreso automático) |
| `reportes_personales` | Reportes → se guarda al abrir la pestaña |
| `historial` + `detalle_historial` | Historial de movimientos |
| `onboarding` | Tutorial (dispositivo + por usuario tras login) |
| `config_sistema` | Panel admin → configuración global |

## Flujos importantes

1. **Registro** → crea fila en `cuentas` + `onboarding` (completado: false).
2. **Login** → si onboarding no completado → pantalla tutorial → `onboarding.completado = true`.
3. **Movimiento** → insert en `movimientos` + recalcula `cuentas.saldo_actual`.
4. **Perfil** → lee/guarda `presupuestos` y `metas_ahorro`.
5. **Reportes** → calcula mes actual/anterior y upsert en `reportes_personales`.

## RLS

Si alguna operación falla con error de permisos, ejecuta `rls_policies.sql` en el SQL Editor de Supabase.

## IDs UUID

Nunca envíes IDs numéricos en inserts; deja `id: ''` para que Postgres genere el UUID.
