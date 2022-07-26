
PYRO_STATE_NULL     = 0 --无效
PYRO_STATE_VIGOROUS = 1 --旺盛
PYRO_STATE_BERSERK  = 2 --狂暴

--颜色转换
local function hexTOc4f(hexR,hexG,hexB)return {a=1,r=hexR/255,g=hexG/255,b=hexB/255}end

--pyroName                id    colorOfParticle                var
PYRO_DiYan             = {id=12,color=hexTOc4f(0xEA,0xF5,0x83),var=nil  } --var不需要
PYRO_XuWuTunYan        = {id=11,color=hexTOc4f(0xA1,0x66,0xFF),var={0.3,1}} --释放离场技几率
PYRO_JingLianYaoHuo    = {id=10,color=hexTOc4f(0x8E,0xB7,0xFF),var={0.3,1}} --额外行动回合几率
PYRO_JinDiFenTianYan   = {id= 9,color=hexTOc4f(0xFF,0xF6,0x2B),var={0.3,1}} --释放入场技几率
PYRO_ShengLingZhiYan   = {id= 8,color=hexTOc4f(0x60,0xEA,0x41),var={0.3,1}} --摆脱控制几率
PYRO_JiuYouJinZuHuo    = {id= 7,color=hexTOc4f(0xEA,0xD3,0x41),var={1,4}} --免疫物理伤害次数
PYRO_SanQianYanYanHuo  = {id= 6,color=hexTOc4f(0x9A,0x30,0xB7),var={1,4}} --免疫法术伤害次数
PYRO_GuLingLengHuo     = {id= 5,color=hexTOc4f(0x82,0x81,0xC7),var={1,0}} --所有技能最多冷却回合数
PYRO_YunLuoXinYan      = {id= 4,color=hexTOc4f(0x30,0x5B,0x7A),var={0.3,1}} --被控制时回复满血的几率
PYRO_HaiXinYan         = {id= 3,color=hexTOc4f(0x1E,0x70,0xC1),var={0,0.2}} --治疗时提高物防法防的百分比
PYRO_QingLianDiXinHuo  = {id= 2,color=hexTOc4f(0x04,0x6A,0x53),var={0.5,1.5}} --未受伤时额外增加基础攻击的百分比
PYRO_WanShouLingYan    = {id= 1,color=hexTOc4f(0xC1,0x3E,0x1E),var={false,true}} --是否命中（无视闪避，但可以被免疫）
PYRO_BaHuangPoMieYan   = {id= 0,color=hexTOc4f(0x00,0x00,0x00),var={1,1}}
PYRO_HongLianYeHuo     = {id= 0,color=hexTOc4f(0x00,0x00,0x00),var={1,1}}
PYRO_JiuYouFengYan     = {id= 0,color=hexTOc4f(0x00,0x00,0x00),var={1,1}}
PYRO_JiuLongLeiGangHuo = {id= 0,color=hexTOc4f(0x00,0x00,0x00),var={1,1}}
PYRO_GuiLingDiHuo      = {id= 0,color=hexTOc4f(0x00,0x00,0x00),var={1,1}}
PYRO_HuoYunShuiYan     = {id= 0,color=hexTOc4f(0x00,0x00,0x00),var={1,1}}
PYRO_BingFengYan       = {id= 0,color=hexTOc4f(0x00,0x00,0x00),var={1,1}}
PYRO_FengLeiNuYan      = {id= 0,color=hexTOc4f(0x00,0x00,0x00),var={1,1}}
PYRO_LongFengYan       = {id= 0,color=hexTOc4f(0x00,0x00,0x00),var={1,1}}
PYRO_LiuDaoLunHuiYan   = {id= 0,color=hexTOc4f(0x00,0x00,0x00),var={1,1}}
PYRO_XuanHuangYan      = {id= 0,color=hexTOc4f(0x00,0x00,0x00),var={1,1}}
