_G.ColorUtil={}

function ColorUtil.init( self )
    local Const  = _G.Const
    self.m_color = {}
    self.m_color[Const.CONST_COUNTRY_DEFAULT]    = {r=158,  g=156,   b=154,  a=255}  --颜色-灰
    self.m_color[Const.CONST_COLOR_WHITE]        = {r=255,  g=255,   b=255,  a=255}  --颜色-白
    self.m_color[Const.CONST_COLOR_GREEN]        = {r=8,  g=216,   b=16  ,  a=255}  --颜色-绿
    self.m_color[Const.CONST_COLOR_BLUE]         = {r=35,  g=116,   b=248,  a=255}  --颜色-蓝
    self.m_color[Const.CONST_COLOR_VIOLET]       = {r=241,  g=32  ,   b=249,  a=255}  --颜色-紫
    self.m_color[Const.CONST_COLOR_GOLD]         = {r=218,  g=220,   b=7  ,  a=255}  --颜色-金
    self.m_color[Const.CONST_COLOR_ORANGE]       = {r=237,  g=130,   b=3  ,  a=255}  --颜色-橙
    self.m_color[Const.CONST_COLOR_RED]          = {r=229,  g=13  ,   b=84  ,  a=255}  --颜色-红
    self.m_color[Const.CONST_COLOR_CYANBLUE]     = {r=0  ,  g=255,   b=255,  a=255}  --颜色-青
    self.m_color[Const.CONST_COLOR_LABELBLUE]    = {r=127,  g=219,   b=198,  a=255}  --颜色-标签蓝
    self.m_color[Const.CONST_COLOR_BROWN]        = {r=89,  g=34,   b=1 ,  a=255}  --颜色-棕色
    self.m_color[Const.CONST_COLOR_SPRINGGREEN]  = {r=0,  g=255,   b=114  ,  a=255}  --颜色-中春绿
    self.m_color[Const.CONST_COLOR_BRIGHTYELLOW] = {r=242,  g=247,   b=191,  a=255}  --颜色-中春黄
    self.m_color[Const.CONST_COLOR_DARKPURPLE]   = {r=94,  g=54  ,   b=68,  a=255}  --颜色-暗紫
    self.m_color[Const.CONST_COLOR_DARKBLUE]     = {r=0  ,  g=102,   b=255,  a=255}  --颜色-暗蓝
    self.m_color[Const.CONST_COLOR_DARKGOLD]     = {r=128,  g=108,   b=0  ,  a=255}  --颜色-暗金
    self.m_color[Const.CONST_COLOR_DARKGREEN]    = {r=0  ,  g=128,   b=0  ,  a=255}  --颜色-暗绿
    self.m_color[Const.CONST_COLOR_DARKRED]      = {r=128,  g=0  ,   b=0  ,  a=255}  --颜色-暗红
    self.m_color[Const.CONST_COLOR_DARKWHITE]    = {r=128,  g=128,   b=128,  a=255}  --颜色-暗白
    self.m_color[Const.CONST_COLOR_DARKORANGE]   = {r=135,  g=49 ,   b=5  ,  a=255}  --颜色-暗橙
    self.m_color[Const.CONST_COLOR_PBLUE]        = {r=89,  g=34,   b=1,  a=255}  --颜色-普蓝
    self.m_color[Const.CONST_COLOR_LBLUE]        = {r=251,  g=248,   b=230,  a=255}  --颜色-亮蓝
    self.m_color[Const.CONST_COLOR_PSTROKE]      = {r=128  ,  g=96 ,   b=0 ,  a=255}  --颜色-普通描边
    self.m_color[Const.CONST_COLOR_XSTROKE]      = {r=152 ,  g=62,   b=1,  a=255}  --颜色-选中描边
    self.m_color[Const.CONST_COLOR_ORED]         = {r=193,  g=17 ,   b=17  ,  a=255}  --颜色-橙红色
    self.m_color[Const.CONST_COLOR_OSTROKE]      = {r=152,  g=62,   b=1  ,  a=255}  --颜色-橙色描边

    self.m_color[Const.CONST_COLOR_YELLOW]       = {r=252,  g=231,   b=0  ,  a=255}  --颜色-黄
    self.m_color[Const.CONST_COLOR_HBLUE]        = {r=113,  g=144,   b=185,  a=255}  --颜色-灰蓝
    self.m_color[Const.CONST_COLOR_LIGHTBLUE]    = {r=184,  g=221,   b=254,  a=255}  --颜色-浅蓝
    self.m_color[Const.CONST_COLOR_SKYBLUE]      = {r=68 ,  g=152,   b=206,  a=255}  --颜色-天蓝
    self.m_color[Const.CONST_COLOR_YELLOWISH]    = {r=119,  g=91,   b=71  ,  a=255}  --颜色-土黄
    self.m_color[Const.CONST_COLOR_PALEGREEN]    = {r=141,  g=109,   b=95,  a=255}  --颜色-浅黄
    self.m_color[Const.CONST_COLOR_GRASSGREEN]   = {r=186 ,  g=255,   b=0 ,  a=255}  --颜色-草绿

    self.m_rgbColor={}
    for colorIdx,table in pairs(self.m_color) do
        self.m_rgbColor[colorIdx]=cc.c3b(table.r,table.g,table.b)
    end

    self.m_yBtnOutColor=self.m_color[Const.CONST_COLOR_OSTROKE]
end

function ColorUtil.getYBtnOutColor(self)
    return self.m_yBtnOutColor
end

function ColorUtil.getColor(self,_colorID)
    return self.m_color[_colorID]
end

function ColorUtil.getRGB( self, _colorID )
    local rgb=self.m_rgbColor[_colorID] or cc.c3b(0,0,0)
    return rgb
end

function ColorUtil.getRGBA( self, _colorID )
    local rgba=self.m_color[_colorID] or cc.c4b(0,0,0,255)
    return rgba
end

function ColorUtil.getFloatRGBA( self, _colorID )
    local colorT=self.m_color[_colorID]
    if colorT~=nil then
        return cc.c4f( colorT.r/255, colorT.g/255, colorT.b/255, colorT.a/255)
    else --error 没有找到 显示黑色
        return cc.c4f( 0, 0, 0, 1)
    end
end

function ColorUtil.setLabelColor(self, label, _colorID )
    label:setColor(self.m_rgbColor[_colorID])
end

_G.ColorUtil:init()