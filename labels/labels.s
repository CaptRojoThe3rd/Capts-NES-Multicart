
Button_A 						= $80
Button_B 						= $40
Button_Select 					= $20
Button_Start 					= $10
DPad_Up 						= $8
DPad_Down 						= $4
DPad_Left 						= $2
DPad_Right 						= $1

Mirroring_Horizontal			= $50
Mirroring_Vertical				= $44
Mirroring_SingleA				= $00
Mirroring_SingleB				= $55
Mirroring_SingleC				= $aa
Mirroring_Fill					= $ff
Mirroring_Diagonal				= $14

PPUCtrl_NMI						= $80
PPUCtrl_Spr8x16					= $20
PPUCtrl_Bg1000					= $10
PPUCtrl_Spr1000					= $08
PPUCtrl_VRAMInc					= $04

PPUMask_EBlue					= $80
PPUMask_EGreen					= $40
PPUMask_ERed					= $20
PPUMask_Spr						= $10
PPUMask_Bg						= $08
PPUMask_SprL8					= $04
PPUMask_BgL8					= $02
PPUMask_Grayscale				= $01

PPUCtrl_OnNormal				= PPUCtrl_NMI|PPUCtrl_Spr1000
PPUCtrl_OffNormal				= 0
PPUMask_OnNormal				= PPUMask_Bg|PPUMask_BgL8|PPUMask_Spr|PPUMask_SprL8
PPUMask_OffNormal				= 0


; Global Vars - Zeropage uses $00-$2f
temp							= $00 ; 16 bytes, $00-$0f

nmi_done						= $10
nmi_ready						= $11

current_program					= $12

scroll_x						= $13
scroll_y						= $14
scroll_nt						= $15

oam_buffer_used					= $16
oam_buffer_index				= $17
oam_buffer_buffer				= $18 ; 4 bytes, $18-$1b

ppuctrl_copy					= $1c

controller_1_old				= $1d
controller_1_current			= $1e
controller_1_new				= $1f

controller_2_old				= $20
controller_2_current			= $21
controller_2_new				= $22

vram_buffer_index				= $23

rng_data						= $24 ; 4 bytes, $24-$27



palette_1						= $100 ; 32 bytes, $100-$11f
palette_2						= $120 ; 32 bytes, $120-$13f

vram_buffer_adr_lo				= $140 ; 16 bytes, $140-$14f
vram_buffer_adr_hi				= $150 ; 16 bytes, $150-$15f
vram_buffer_data				= $160 ; 16 bytes, $160-$16f

cold_reset_detection			= $170 ; 16 bytes, $170-$17f

oam_buffer						= $200 ; 256 bytes, $200-$2ff

