require "Core.Module.Common.UIItem"
require "Core.Module.Common.ProductCtrl"
require "Core.Module.Backpack.data.BackPackCDData"

require "Core.Scene.SceneInfosGetManager"

InstanceFbItem = class("InstanceFbItem", UIItem);

--[[
-monster_display= []
--icon_id= [fb_zx05]
drop--1= [351000_1]
|    --2= [103_1]
--number= [5]
--enter_type= [1]
--position_x= [1980_2260]
--time= [10]
first_pass_reward--1= [351004_2]
reward--1= [351000_1_60_50]
|      --2= [351001_1_15_50]
|      --3= [351002_1_15_50]
|      --4= [351003_1_15_50]
|      --5= [351004_1_15_50]
--position_z= [-5270_-4850]
--open_map_condition= [750004]
--is_hire= [false]
--desc= [海妖皇，纵然你凶威滔天又何妨？]
--sweep_num= [0]
--exp= [1300]
--other_condition= [0]
chapter_reward--1= [8_502030]
|              --2= [16_502031]
|              --3= [24_502032]
|              --4= [32_502033]
|              --5= [40_502034]
|              --6= [48_502035]
pass_conditions--1= [1_60_0]
|               --2= [2_300_0]
|               --3= [5_0_0]
--toward= [180]
npc--1= [0]
--inst_name= [海皇阁]
--level= [20]
--failed_conditions= []
--money= [200]
--id= [750005]
--min_num= [1]
--type= [1]
--sweep_star= [3]
--kind= [1]
--map_id= [703033]
sweep_drop--1= []
--need_power= [18000]
--name= [勇斗海妖皇]
--instance_end_condition= [7_131016_1]
]]
InstanceFbItem.currInFbData = nil;

InstanceFbItem.Pivot = {
    TopLeft = 0,
    Top = 1,
    TopRight = 2,
    Left = 3,
    Center = 4,
    Right = 5,
    BottomLeft = 6,
    Bottom = 7,
    BottomRight = 8,
}

function InstanceFbItem:New()
    self = { };
    setmetatable(self, { __index = InstanceFbItem });
    return self
end
 
function InstanceFbItem:UpdateItem(data)
    self.data = data

end

function InstanceFbItem:Init(gameObject, data)

    self.gameObject = gameObject;

    self.fatPoint = UIUtil.GetChildByName(self.gameObject, "Transform", "fatPoint");


    self.fbIcon = UIUtil.GetChildByName(self.gameObject, "UITexture", "fbIcon");
    self.lockIcon = UIUtil.GetChildByName(self.gameObject, "UISprite", "lockIcon");

    self.selectIcon = UIUtil.GetChildByName(self.gameObject, "UISprite", "selectIcon");

    for i = 1, 3 do
        self["star" .. i] = UIUtil.GetChildByName(self.gameObject, "UISprite", "star" .. i);
    end

    self.fb_name_txt = UIUtil.GetChildByName(self.gameObject, "UILabel", "fb_name_txt");
    self.fbIcon_ptween = UIUtil.GetChildByName(self.gameObject, "UIPlayTween", "fbIcon");

    self.tween = UIUtil.GetChildByName(self.gameObject, "Transform", "tween");
    self.pl = UIUtil.GetChildByName(self.tween, "Transform", "pl");

    self.lvLimTxt = UIUtil.GetChildByName(self.gameObject, "UILabel", "lvLimTxt");

    self.rfatPoint = UIUtil.GetChildByName(self.pl, "Transform", "rfatPoint");

    self.fightTxt = UIUtil.GetChildByName(self.pl, "UILabel", "fightTxt");
    -- self.tiaozhantimeNumTxt = UIUtil.GetChildByName(self.pl, "UILabel", "tiaozhantimeNumTxt");
    self.decTxt = UIUtil.GetChildByName(self.pl, "UILabel", "decTxt");

    self.map_product1 = UIUtil.GetChildByName(self.pl, "Transform", "map_product1");
    self.map_product2 = UIUtil.GetChildByName(self.pl, "Transform", "map_product2");
    self.map_product3 = UIUtil.GetChildByName(self.pl, "Transform", "map_product3");

    self.numShowPanel = UIUtil.GetChildByName(self.pl, "Transform", "numShowPanel");
    self.numLabel = UIUtil.GetChildByName(self.numShowPanel, "UILabel", "value_txt");
    self.addNumBt = UIUtil.GetChildByName(self.numShowPanel, "UIButton", "addNumBt");

    local num = InstanceDataManager.GetElsenum();
    self.numLabel.text = "" .. num;

    self._map_product1Ctrls1 = ProductCtrl:New();
    self._map_product1Ctrls1:Init(self.map_product1, { hasLocke = true, use_sprite = true, iconType = ProductCtrl.IconType_rectangle });
    self._map_product1Ctrls1:SetOnClickBtnHandler(ProductCtrl.TYPE_FROM_OTHER);

    self._map_product2Ctrls1 = ProductCtrl:New();
    self._map_product2Ctrls1:Init(self.map_product2, { hasLocke = true, use_sprite = true, iconType = ProductCtrl.IconType_rectangle });
    self._map_product2Ctrls1:SetOnClickBtnHandler(ProductCtrl.TYPE_FROM_OTHER);

    self._map_product3Ctrls1 = ProductCtrl:New();
    self._map_product3Ctrls1:Init(self.map_product3, { hasLocke = true, use_sprite = true, iconType = ProductCtrl.IconType_rectangle });
    self._map_product3Ctrls1:SetOnClickBtnHandler(ProductCtrl.TYPE_FROM_OTHER);

    -- self.resetBt = UIUtil.GetChildByName(self.pl, "UIButton", "resetBt");
    self.saodangBt = UIUtil.GetChildByName(self.pl, "UIButton", "saodangBt");
    self.tiaozhanBt = UIUtil.GetChildByName(self.pl, "UIButton", "tiaozhanBt");


    self._onClickBtn = function(go) self:_OnClickBtn(self) end
    UIUtil.GetComponent(self.fbIcon, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn);


    --[[
    self._onresetBt = function(go) self:_OnresetBt(self) end
    UIUtil.GetComponent(self.resetBt, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onresetBt);
    ]]
    self._onsaodangBt = function(go) self:_OnsaodangBt(self) end
    UIUtil.GetComponent(self.saodangBt, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onsaodangBt);

    self._ontiaozhanBt = function(go) self:_OntiaozhanBt(self) end
    UIUtil.GetComponent(self.tiaozhanBt, "LuaUIEventListener"):RegisterDelegate("OnClick", self._ontiaozhanBt);

    self._onClickaddNumBt = function(go) self:_OnClickaddNumBt(self) end
    UIUtil.GetComponent(self.addNumBt, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickaddNumBt);



    self:SetSelected(false);
    self.isShowInfo = false;

    self:SetLock(false);
    self.checkBoxSelected = false;

    self:SetData(data);
end

function InstanceFbItem:_OnClickaddNumBt()
    InstanceDataManager.TryBuyTineConfirm(InstanceDataManager.shiyongQuan[InstanceDataManager.InstanceType.MainInstance], self.data.id);
end


function InstanceFbItem:SetLock(v)

    self.lock = v;

    if v then
        self.lockIcon.gameObject:SetActive(true);
        ColorDataManager.SetGray(self.fbIcon);

        for i = 1, 3 do
            self["star" .. i].gameObject:SetActive(false);
        end
        self.fbIcon_ptween.enabled = false;
    else
        self.lockIcon.gameObject:SetActive(false);
        ColorDataManager.UnSetGray(self.fbIcon);

        for i = 1, 3 do
            self["star" .. i].gameObject:SetActive(true);
        end
        self.fbIcon_ptween.enabled = true;
    end

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

function InstanceFbItem:SetData(v)
    self.data = v;
    self:UpData()

    local me = HeroController:GetInstance();
    local heroInfo = me.info;
    local my_lv = heroInfo.level;

    if my_lv >= self.data.level then
        self.lvLimTxt.gameObject:SetActive(false);
    else
        self.lvLimTxt.text = LanguageMgr.Get("Activity/ActivityFBItem/label5", { lv = GetLvDes1(self.data.level) })
        self.lvLimTxt.gameObject:SetActive(true);
    end


end


function InstanceFbItem:GetFitMyCareerPro(list)
    local my_info = HeroController:GetInstance().info;
    local my_career = tostring(my_info:GetCareer());

    local res = { };
    for key, value in pairs(list) do
        local arr = ConfigSplit(value);

        if arr[3] ~= nil and arr[3] == my_career then
            table.insert(res, value);
        end

    end

    return res;
end

function InstanceFbItem:UpData()



    if self._mainTexturePath == nil then

        UIUtil.RecycleTexture(self._mainTexturePath);
        self._mainTexturePath = nil;

    end

    self._mainTexturePath = "Instance_FBIcons/" .. self.data.icon_id;
    self.fbIcon.mainTexture = UIUtil.GetTexture(self._mainTexturePath)

    if self.fbIcon.mainTexture == nil then
        self._mainTexturePath = "Instance_FBIcons/fb_zx01";
        self.fbIcon.mainTexture = UIUtil.GetTexture(self._mainTexturePath)
    end

    self.fbIcon.enabled = false;
    self.fbIcon.enabled = true;

    self.fightTxt.text = self.data.need_power;
    self.decTxt.text = self.data.desc;
    self.fb_name_txt.text = self.data.name;

    local first_pass_reward = InstanceDataManager.Get_First_pass_reward(self.data.id);
    local drop = self:GetFitMyCareerPro(self.data.drop) ;

    local drop1_arr = ConfigSplit(drop[1]);
    local drop2_arr = ConfigSplit(drop[2]);

    if self._first_pass_reward_Product == nil then
        self._first_pass_reward_Product = ProductInfo:New();
    end

    if self._drop1_Product == nil then
        self._drop1_Product = ProductInfo:New();
    end


    if self._drop2_Product == nil then
        self._drop2_Product = ProductInfo:New();
    end


    self._first_pass_reward_Product:Init(first_pass_reward);

    self._drop1_Product:Init( { spId = drop1_arr[1] + 0, am = drop1_arr[2] + 0 });
    self._drop2_Product:Init( { spId = drop2_arr[1] + 0, am = drop2_arr[2] + 0 });


    self._map_product1Ctrls1:SetData(self._first_pass_reward_Product);
    self._map_product2Ctrls1:SetData(self._drop1_Product);
    self._map_product3Ctrls1:SetData(self._drop2_Product);

    --
    local hasPassInfo = InstanceDataManager.GetHasPassById(self.data.id);

    for i = 1, 3 do
        self["star" .. i].spriteName = "star2";
    end
    -- self.lvLimTxt
    -- self.elseTime = self.data.number;

    -- {"instId":"753001","s":0,"t":0,"ut":-1}
    if hasPassInfo ~= nil then
        local star_num = hasPassInfo.s;
        local play_time = hasPassInfo.t;
        -- self.elseTime = self.data.number - play_time;

        if star_num > 3 then
            log("error:  star_num > 3 -------------- " .. star_num);
            star_num = 3;
        end

        for i = 1, star_num do
            self["star" .. i].spriteName = "star1";
        end

    end


    local num = InstanceDataManager.GetElsenum();
    self.numLabel.text = "" .. num;

    -- 检测是否可以开启
    self.saodangBt.gameObject:SetActive(true);

    self.canOpenObj = InstanceDataManager.CheckMapCanPlay(self.data, 0);
    self.newOpen = false;
    -- if self.canOpenObj.can and self.elseTime > 0 then
    local elseTime = InstanceDataManager.GetElsenum();

    if self.canOpenObj.can and elseTime > 0 then



        self:SetLock(false);

        local hpinfo = InstanceDataManager.GetHasPassById(self.data.id);

        if hpinfo ~= nil and hpinfo.s >= self.data.sweep_star then
            self.saodangBt.gameObject:SetActive(true);
        else
            self.saodangBt.gameObject:SetActive(false);
            self.newOpen = true;
        end

        ------------------------优先指定之前进入过的副本  -----------------------------------
        if InstanceFbItem.currInFbData ~= nil then
            if self.data.id == InstanceFbItem.currInFbData.id then
                self.newOpen = true;

            else
                self.newOpen = false;
            end
        end


    else

        local hpinfo = InstanceDataManager.GetHasPassById(self.data.id);

        if hpinfo ~= nil and hpinfo.s >= self.data.sweep_star then
            self.saodangBt.gameObject:SetActive(true);
        else
            self.saodangBt.gameObject:SetActive(false);
            self.newOpen = true;
        end

        -- 没有剩余次数时：副本灰掉显示
        -- if self.canOpenObj.can and self.elseTime <= 0 then
        if self.canOpenObj.can and elseTime <= 0 then
            self:SetLock(false);
            ColorDataManager.SetGray(self.fbIcon);
        else
            self:SetLock(true);

        end
    end



end

function InstanceFbItem:SetSelected(v)
    self.selectIcon.gameObject:SetActive(v);
end

function InstanceFbItem:PlayTween(v)
    self.isShowInfo = v;
    self.fbIcon_ptween:Play(v);
end

function InstanceFbItem:SetParent(parent, index)
    self.parent = parent;
    self.index = index;

    local pos = self.gameObject.transform.localPosition;
    self.oldPos = Vector3.New(pos.x, pos.y, 0);
end

function InstanceFbItem:GetX()

    return self.fatPoint.position.x;
end


function InstanceFbItem:GetRX()

    return self.rfatPoint.position.x;
end

function InstanceFbItem:UpPos()
    Util.SetLocalPos(self.gameObject, self.oldPos.x, self.oldPos.y, self.oldPos.z)

    --    self.gameObject.transform.localPosition = self.oldPos;
end


function InstanceFbItem:_OnClickBtn()



    if self.parent ~= nil then

        if self.lock then
            MsgUtils.ShowTips(nil, nil, nil, self.canOpenObj.msg);
            return;
        end


        if self.parent.currSelected ~= nil and self.parent.currSelected ~= self then
            self.parent.currSelected:SetSelected(false);

            if self.parent.currSelected.isShowInfo then
                self.parent.currSelected:PlayTween(false);
            end

        end

        self.parent:SetCurrItemSelected(self);


        if self.isShowInfo then
            self.isShowInfo = false;
            self.parent.currSelected:SetSelected(false);
        else
            self.isShowInfo = true;
            self.parent.currSelected:SetSelected(true);
        end


    end

end





-- 需要判断是否 有挑战次数
function InstanceFbItem:_OnsaodangBt()
    -- if self.elseTime > 0 then
    local elseTime = InstanceDataManager.GetElsenum();



    if elseTime > 0 then

        InstancePanelProxy.TrySaodang(self.data.id);
    else
        InstanceDataManager.TryBuyTineConfirm(InstanceDataManager.shiyongQuan[InstanceDataManager.InstanceType.MainInstance], self.data.id);
    end

end

-- 剩余次数：

--[[

i.剩余次数>0时，点击“挑战”按钮，进入副本
ii.剩余次数=0，重置次数>0时，点击“挑战”按钮，弹出提示框，询问是否消耗30仙玉重置副本次数
iii. 剩余次数=0，重置次数=0时，点击“挑战”按钮，系统提示：副本次数不足！提示文字红色显示

]]
function InstanceFbItem:_OntiaozhanBt()


    local elseTime = InstanceDataManager.GetElsenum();

    if elseTime > 0 then
        -- 进入副本
        ModuleManager.SendNotification(InstancePanelNotes.CLOSE_INSTANCEPANEL);
        -- 关闭活动界面
        ModuleManager.SendNotification(ActivityNotes.CLOSE_ACTIVITY);

        InstanceFbItem.currInFbData = self.data;
        GameSceneManager.GoToFB(self.data.id)




    else
        -- self:_OnresetBt();
        InstanceDataManager.TryBuyTineConfirm(InstanceDataManager.shiyongQuan[InstanceDataManager.InstanceType.MainInstance], self.data.id);
    end


end


function InstanceFbItem:Check_currInFbData()



    if InstanceFbItem.currInFbData ~= nil then

        if self.data.id == InstanceFbItem.currInFbData.id then
            -- 展开

            self:_OnClickBtn();
            self.fbIcon_ptween.enabled = true;
            self:PlayTween(true);

        end

    end


end


function InstanceFbItem:SetActive(v)
    self.gameObject.gameObject:SetActive(v);
end

function InstanceFbItem:Dispose()


    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn = nil;


    UIUtil.GetComponent(self.fbIcon, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn = nil;

    UIUtil.GetComponent(self.addNumBt, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickaddNumBt = nil;


    -- UIUtil.GetComponent(self.resetBt, "LuaUIEventListener"):RemoveDelegate("OnClick");

    UIUtil.GetComponent(self.saodangBt, "LuaUIEventListener"):RemoveDelegate("OnClick");

    UIUtil.GetComponent(self.tiaozhanBt, "LuaUIEventListener"):RemoveDelegate("OnClick");

    -- self._onresetBt = nil;
    self._onsaodangBt = nil;
    self._ontiaozhanBt = nil;

    self.parent = nil;
    self.gameObject = nil;

    self._map_product1Ctrls1:Dispose();
    self._map_product2Ctrls1:Dispose();
    self._map_product3Ctrls1:Dispose();

    if self._mainTexturePath then
        UIUtil.RecycleTexture(self._mainTexturePath);
        self._mainTexturePath = nil;
        -- self.fbIcon.mainTexture = nil
    end

    self.gameObject = nil;

    self.fatPoint = nil;
    self.rfatPoint = nil;

    self.fbIcon = nil;
    self.lockIcon = nil;

    self.selectIcon = nil;

    for i = 1, 3 do
        self["star" .. i] = nil;
    end

    self.fb_name_txt = nil;
    self.fbIcon_ptween = nil;

    self.tween = nil;
    self.pl = nil;

    self.fightTxt = nil;
    -- self.tiaozhantimeNumTxt = nil;
    self.decTxt = nil;

    self.map_product1 = nil;
    self.map_product2 = nil;
    self.map_product3 = nil;

    self._map_product1Ctrls1 = nil;

    self._map_product2Ctrls1 = nil;

    self._map_product3Ctrls1 = nil;

    -- self.resetBt = nil;
    self.saodangBt = nil;
    self.tiaozhanBt = nil;


    self._onClickBtn = nil;

    -- self._onresetBt = nil;

    self._onsaodangBt = nil;

    self._ontiaozhanBt = nil;


end