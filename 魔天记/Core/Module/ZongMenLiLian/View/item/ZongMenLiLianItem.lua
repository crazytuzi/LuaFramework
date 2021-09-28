require "Core.Module.Common.UIItem"


ZongMenLiLianItem = class("ZongMenLiLianItem", UIItem);

ZongMenLiLianItem.currSelected = nil;

ZongMenLiLianItem.MESSAGE_ITEM_SELECTED_CHANGE = "MESSAGE_ITEM_SELECTED_CHANGE";



function ZongMenLiLianItem:New()
    self = { };
    setmetatable(self, { __index = ZongMenLiLianItem });
    return self
end
 
function ZongMenLiLianItem:UpdateItem(data)
    self.data = data

end

function ZongMenLiLianItem:Init(gameObject, data)

    self.gameObject = gameObject;



    self.fbIcon = UIUtil.GetChildByName(self.gameObject, "UITexture", "fbIcon");
    self.selectIcon = UIUtil.GetChildByName(self.gameObject, "UISprite", "selectIcon");
    self.levelTxt = UIUtil.GetChildByName(self.gameObject, "UILabel", "levelTxt");
    self.errlevelTxt = UIUtil.GetChildByName(self.gameObject, "UILabel", "errlevelTxt");

    self._onClickBtn = function(go) self:_OnClickBtn(self) end
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn);

    self:SetSelected(false);
    self:SetData(data);
end


--[[
['id'] = 1,	--阶段id
		['min_level'] = 25,	--最小等级
		['experience_num'] = 30,	--历练次数
		['drop'] = {'400002_2','400003_2'},	--几率掉落掉落显示
		['desc'] = '各大宗门为了提升本门实力，共同对抗魔主，纷纷派出弟子前往中天各地历练',	--副本描述
]]
function ZongMenLiLianItem:SetData(v)
    self.data = v;
    self:UpData()
end

function ZongMenLiLianItem:UpData()

    if self.data.icon_id ~= nil then
        --  self.fbIcon.spriteName = self.data.icon_id .. "";

        if self._mainTexturePath then
            UIUtil.RecycleTexture(self._mainTexturePath);
            self._mainTexturePath = nil;
            -- self.fbIcon.mainTexture = nil;
        end

        self._mainTexturePath = "Instance_FBIcons/" .. self.data.icon_id;
        self.fbIcon.mainTexture = UIUtil.GetTexture(self._mainTexturePath)

        if self.fbIcon.mainTexture == nil then
            self._mainTexturePath = "Instance_FBIcons/fb_zx01";
            self.fbIcon.mainTexture = UIUtil.GetTexture(self._mainTexturePath)
        end

    end


    local me = HeroController:GetInstance();
    local heroInfo = me.info;
    local my_lv = heroInfo.level;

    if my_lv >= self.data.min_level then
        self.levelTxt.text = self.data.min_level .. LanguageMgr.Get("ZongMenLiLian/ZongMenLiLianItem/label1");
        self.levelTxt.gameObject:SetActive(true);
        self.errlevelTxt.gameObject:SetActive(false);
        self.canPlay = true;
    else
        self.errlevelTxt.text = self.data.min_level .. LanguageMgr.Get("ZongMenLiLian/ZongMenLiLianItem/label2");
        self.levelTxt.gameObject:SetActive(false);
        self.errlevelTxt.gameObject:SetActive(true);

        ColorDataManager.SetGray(self.fbIcon);
        self.canPlay = false;
    end

end

function ZongMenLiLianItem:SetSelected(v)
    self.selectIcon.gameObject:SetActive(v);
end


function ZongMenLiLianItem:_OnClickBtn()

    if ZongMenLiLianItem.currSelected ~= nil then
        ZongMenLiLianItem.currSelected:SetSelected(false);
    end

    ZongMenLiLianItem.currSelected = self;
    ZongMenLiLianItem.currSelected:SetSelected(true);

    

    MessageManager.Dispatch(ZongMenLiLianItem, ZongMenLiLianItem.MESSAGE_ITEM_SELECTED_CHANGE, self);


end


function ZongMenLiLianItem:CheckPiPeiSelect(pipeiData)

    if self.data ~= nil and self.data.id == pipeiData.id then
        self:_OnClickBtn();
        return true;
    else
        self:SetSelected(false);
    end

    return false;
end


function ZongMenLiLianItem:SetActive(v)
    self.gameObject.gameObject:SetActive(v);
end

function ZongMenLiLianItem:Dispose()

    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn = nil;

    self.gameObject = nil;

    if self._mainTexturePath then
        UIUtil.RecycleTexture(self._mainTexturePath);
        self._mainTexturePath = nil;
    end

    self.fbIcon = nil;
    self.selectIcon = nil;
    self.levelTxt = nil;
    self.errlevelTxt = nil;

end