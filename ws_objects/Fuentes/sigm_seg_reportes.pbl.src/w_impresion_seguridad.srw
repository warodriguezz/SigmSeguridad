$PBExportHeader$w_impresion_seguridad.srw
forward
global type w_impresion_seguridad from w_base_preview
end type
end forward

global type w_impresion_seguridad from w_base_preview
string title = "Seguridad"
end type
global w_impresion_seguridad w_impresion_seguridad

on w_impresion_seguridad.create
int iCurrent
call super::create
end on

on w_impresion_seguridad.destroy
call super::destroy
if IsValid(MenuID) then destroy(MenuID)
end on

type st_titulo from w_base_preview`st_titulo within w_impresion_seguridad
end type

type st_fondo from w_base_preview`st_fondo within w_impresion_seguridad
end type

type dw_principal from w_base_preview`dw_principal within w_impresion_seguridad
end type

type st_menuruta from w_base_preview`st_menuruta within w_impresion_seguridad
end type

type dw_filtro from w_base_preview`dw_filtro within w_impresion_seguridad
end type

type uo_visualizar from w_base_preview`uo_visualizar within w_impresion_seguridad
end type

