local Util = require "Zeus.Logic.Util"
local Item = require "Zeus.Model.Item"
local TitleAPI = require "Zeus.Model.Title"

local GotTitleUI = {}
Util.WrapOOPSelf(GotTitleUI)
Util.WrapCreateUI(GotTitleUI)

function GotTitleUI:init(tag, params)
    self.menu = LuaMenuU.Create("xmds_ui/title/title_get.gui.xml", tag)
    self.menu.ShowType = UIShowType.Cover
    
    self.menu:GetComponent("btn_closet").TouchClick = self._self_closeMe
    self.menu:GetComponent("btn_use").TouchClick = self._self_onUseBtnClick
    self.titleImg = self.menu:GetComponent("ib_chmz")
    self.titleText = self.menu:GetComponent("lb_titlename")

    self.attrLabelList = {}
    for i=1,5 do
        self.attrLabelList[i] = self.menu:GetComponent("lb_attValue"..i)
        self.attrLabelList[i].Visible = false
    end
    
    self.menu:SubscribOnEnter(self._self_onEnter)
    self.menu:SubscribOnExit(self._self_onExit)
    self.menu:SubscribOnDestory(self._self_onDestroy)
end

function GotTitleUI:closeMe()
    self.menu:Close()
end

function GotTitleUI:onUseBtnClick()
    TitleAPI.requestSaveTitle(self.titleId)
    self.menu:Close()
end

function GotTitleUI:onDestroy()
    self.menu = nil
    
    setmetatable(self, nil)
    for k,v in pairs(self) do
        self[k] = nil
    end
end

function GotTitleUI:onEnter()
    self.titleId = tonumber(self.menu.ExtParam)
    local rankListData = GlobalHooks.DB.Find("RankList", {RankID=self.titleId})[1]
   
    if rankListData~=nil then
       if rankListData.Show == "-1" then
          self.titleImg.Visible =false
          self.titleText.Visible = true
          self.titleText.Text = rankListData.RankName
          self.titleText.FontColorRGBA = Util.GetQualityColorRGBA(rankListData.RankQColor)
       else
          self.titleImg.Visible = true
          self.titleText.Visible = false
          Util.HZSetImage2(self.titleImg, "#static_n/title_icon/title_icon.xml|title_icon|"..rankListData.Show, true, LayoutStyle.IMAGE_STYLE_BACK_4_CENTER)
       end
    end
    
    self:updateAttr(self.titleId)
end

function GotTitleUI:onExit()

end


function GotTitleUI:updateAttr(titleId)
    local titleInfo = GlobalHooks.DB.Find("RankList", titleId)
    local attrs = Item.FormatAttribute(titleInfo)
    for i=1,5 do
        self.attrLabelList[i].Visible = attrs[i] ~= nil
        if attrs[i] then
            self.attrLabelList[i].Text = Item.AttributeValue2NameValue(attrs[i])
        end
    end
end

return GotTitleUI
