require "Core.Module.Common.UIItem"
require "Core.Module.Common.ProductCtrl"
require "Core.Module.Backpack.data.BackPackCDData"

LSInstanceFbItem = class("LSInstanceFbItem", UIItem);



function LSInstanceFbItem:New()
    self = { };
    setmetatable(self, { __index = LSInstanceFbItem });
    return self
end
 
function LSInstanceFbItem:UpdateItem(data)
    self.data = data

end

function LSInstanceFbItem:Init(gameObject, data)

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

function LSInstanceFbItem:SetParent(parent)
    self.parent = parent;
end


--[[
[750001] = {
		['id'] = 750001,	--编号
		['name'] = '迷失之城',	--副本名称
		['type'] = 1,	--1:主线副本(单人),2:经验副本(单人),3:装备副本（组队）,4:灵石副本（组队）,5:材料副本（组队）,6:竞技场(单人)
		['chapter_reward'] = {'12_502001','24_502002','36_502003','48_502004'},	--章节全三星通关奖励
		['number'] = 1,	--副本次数
		['map_id'] = 703000,	--载入资源
		['kind'] = 1,	--类型
		['open_map_condition'] = '0',	--副本开启条件
		['other_condition'] = 0,	--其它条件
		['icon_id'] = 750001,	--关卡图标
		['need_power'] = 999,	--推荐战力
		['level'] = 13,	--限制等级
		['desc'] = '“哐当”一声，柳铭就将赤蛟的狗头斩了下来1',	--副本描述
		['time'] = 10,	--副本时间
		['position_x'] = '1510_1560',	--x轴随机坐标点
		['position_y'] = '0',	--y轴随机坐标点
		['position_z'] = '800_872',	--z轴随机坐标点
		['toward'] = 180,	--朝向
		['instance_end_condition'] = '7_120042_1',	--副本结束判断条件
		['sweep_star'] = 1,	--扫荡星级
		['pass_conditions'] = {'1_80_0','2_180_0','5_0_0'},	--通关评星
		['first_pass_reward'] = '301000_2',	--首次通关奖励
		['drop'] = {'400000_2','400001_2'},	--几率掉落掉落显示
		['reward'] = 301001,	--副本通关奖励
		['money'] = 1000,	--副本通关灵石奖励
		['exp'] = 20000,	--副本通关经验奖励
]]

function LSInstanceFbItem:SetData(v)
    self.data = v;
    self:UpData()
end

function LSInstanceFbItem:UpData()


    -- self.fbIcon.spriteName = self.data.icon_id .. "";

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

    local me = HeroController:GetInstance();
    local heroInfo = me.info;
    local my_lv = heroInfo.level;

    local insLv = GetLvDes1(self.data.min_level);

    if my_lv >= self.data.min_level then
        self.levelTxt.text = insLv .. LanguageMgr.Get("LSInstance/LSInstanceFbItem/label1");
        self.levelTxt.gameObject:SetActive(true);
        self.errlevelTxt.gameObject:SetActive(false);
        self.canPlay = true;
    else
        self.errlevelTxt.text = insLv .. LanguageMgr.Get("LSInstance/LSInstanceFbItem/label2");
        self.levelTxt.gameObject:SetActive(false);
        self.errlevelTxt.gameObject:SetActive(true);

        ColorDataManager.SetGray(self.fbIcon);
        self.canPlay = false;
    end

end

function LSInstanceFbItem:SetSelected(v)
  
    self.selectIcon.gameObject:SetActive(v);
end


function LSInstanceFbItem:_OnClickBtn()

    if self.parent ~= nil then
        if self.parent.currSelected ~= nil and self.parent.currSelected ~= self then
            self.parent.currSelected:SetSelected(false);
        end
        self.parent:SetCurrItemSelected(self);
        self.parent.currSelected:SetSelected(true);
    end

end

function LSInstanceFbItem:CheckPiPeiSelect(pipeiData)
   
   if self.data ~= nil and self.data.id == pipeiData.id then
      self:_OnClickBtn();
       return true;
   else
      self:SetSelected(false);
   end
    return false;
end

function LSInstanceFbItem:SetActive(v)
    self.gameObject.gameObject:SetActive(v);
end

function LSInstanceFbItem:Dispose()


    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn = nil;

    self.gameObject = nil;

    if self._mainTexturePath then
        UIUtil.RecycleTexture(self._mainTexturePath);
        self._mainTexturePath = nil;
        --  self.fbIcon.mainTexture = nil;
    end

    self.fbIcon = nil;
    self.selectIcon = nil;
    self.levelTxt = nil;
    self.errlevelTxt = nil;

end