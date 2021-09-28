--------------------------------------------------------------------------------------
-- 文件名:	WB_UI_BaXianFilter.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	
-- 日  期:	
-- 版  本:	1.0
-- 描  述:	八仙过海npc筛选界面
-- 应  用:  本例子是用类对象的方式实现
---------------------------------------------------------------------------------------


Game_BaXianFilter = class("Game_BaXianFilter")
Game_BaXianFilter.__index = Game_BaXianFilter

gWeekNpc = {
    [0] = {4,5,6,7,8}, --星期7
    [1] = {1,2,3,4,5}, --星期1
    [2] = {1,2,3,4,5}, --星期2
    [3] = {1,2,3,4,5}, --星期3
    [4] = {1,2,3,4,5}, --星期4
    [5] = {1,2,3,4,5}, --星期5
    [6] = {4,5,6,7,8}, --星期6
}

--gCurNpcShowState = {}

local function onClick_Button_Npc(pSender, nTag)
     if g_BaXianGuoHaiSystem.MyNpcAryLv[nTag] == nil then return end

     local tmpImage = tolua.cast(pSender:getChildAllByName("Image_FuncName" ), "ImageView")
     if g_BaXianGuoHaiSystem.MyNpcAryLv[nTag].bShow == 1 then
        g_BaXianGuoHaiSystem.MyNpcAryLv[nTag].bShow = 0
        tmpImage:loadTexture(getImgByPath("BaXianGuoHai", "Char_XianShi" ))
     else
        g_BaXianGuoHaiSystem.MyNpcAryLv[nTag].bShow = 1
        tmpImage:loadTexture(getImgByPath("BaXianGuoHai", "Char_YinCang" ))
     end

     --更新护送界面
     if g_Game_BaXuanGuoHai then
        g_Game_BaXuanGuoHai:OnNpcShowStateChange()
     end

end

function Game_BaXianFilter:ctor()

end

function Game_BaXianFilter:initWnd()

    self.Button_Npc = {}
    for i = 1, 5 do
        -- 初始化5个npc按钮,注册响应时间
        self.Button_Npc[i] = tolua.cast(self.rootWidget:getChildAllByName("Button_Npc" .. i), "Button")
    end

    return true
end

function Game_BaXianFilter:releaseWnd()
    local var = 0;
end

function Game_BaXianFilter:openWnd()
    --根据当前星期几，初始化npc类型
    local Wday = g_GetServerWday()

    local i = 1
    for k,v in pairs(gWeekNpc[Wday]) do
        if self.Button_Npc[i] then 

            local tbCsvBase = g_DataMgr:getBXGH_NpcBaseCsv(v)
            local strPath = getImgByPath("BaXianGuoHai", tbCsvBase.Icon)
            self.Button_Npc[i]:loadTextures( strPath, strPath, strPath) 
            self.Button_Npc[i]:setTag(v) 
			
			local Image_Check = tolua.cast(self.Button_Npc[i]:getChildAllByName("Image_Check" ), "ImageView")
			Image_Check:loadTexture(strPath)
			
            local tmpImage = tolua.cast(self.Button_Npc[i]:getChildAllByName("Image_FuncName" ), "ImageView")
            if g_BaXianGuoHaiSystem.MyNpcAryLv[v].bShow == 1 then
                tmpImage:loadTexture(getImgByPath("BaXianGuoHai", "Char_YinCang" ))
            else
                tmpImage:loadTexture(getImgByPath("BaXianGuoHai", "Char_XianShi" ))
            end
        end
        i = i+1
    end
	
	for i = 1, 5 do
        -- 初始化5个npc按钮,注册响应时间
        g_SetBtnWithPressImage(self.Button_Npc[i], self.Button_Npc[i]:getTag(), onClick_Button_Npc, true, 1)
    end
end

function Game_BaXianFilter:closeWnd()
    local var = 0;
end

function Game_BaXianFilter:showWndOpenAnimation(funcWndOpenAniCall)
	local Image_BaXianFilterPNL = tolua.cast(self.rootWidget:getChildByName("Image_BaXianFilterPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIAppearAnimation_Scale(Image_BaXianFilterPNL, funcWndOpenAniCall, 1.05, 0.2, Image_Background)
end

function Game_BaXianFilter:showWndCloseAnimation(funcWndCloseAniCall)
	local Image_BaXianFilterPNL = tolua.cast(self.rootWidget:getChildByName("Image_BaXianFilterPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIDisappearAnimation_Scale(Image_BaXianFilterPNL, funcWndCloseAniCall, 1.05, 0.2, Image_Background)
end