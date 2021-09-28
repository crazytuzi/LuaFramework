
require "Core.Module.Friend.controlls.items.YaoQingPiPeiRightItem"

YaoQingPiPeiRightControll = class("YaoQingPiPeiRightControll");


YaoQingPiPeiRightControll.MESSAGE_YAOQINGPIPEIRIGHTCONTROLL_SELECTED_COMPLETE = "MESSAGE_YAOQINGPIPEIRIGHTCONTROLL_SELECTED_COMPLETE";



function YaoQingPiPeiRightControll:New()
    self = { };
    setmetatable(self, { __index = YaoQingPiPeiRightControll });
    return self
end


function YaoQingPiPeiRightControll:Init(gameObject)
    self.gameObject = gameObject;

    self.right_subPanel = UIUtil.GetChildByName(self.gameObject, "Transform", "rightNumPanel/subPanel");
    self.left_subPanel = UIUtil.GetChildByName(self.gameObject, "Transform", "leftNumPanel/subPanel");

    self.lvSelecFat = UIUtil.GetChildByName(self.gameObject, "Transform", "lvSelecFat");

    self.btn_ok = UIUtil.GetChildByName(self.gameObject, "UIButton", "btn_ok");
    self.autoPiPeiCheckBox = UIUtil.GetChildByName(self.gameObject, "UIToggle", "autoPiPeiCheckBox");



    self.timeTxt = UIUtil.GetChildByName(self.gameObject, "UILabel", "timeTxt");
    self.numTxt = UIUtil.GetChildByName(self.gameObject, "UILabel", "numTxt");

    self.right_item_phalanx = UIUtil.GetChildByName(self.right_subPanel, "LuaAsynPhalanx", "table");
    self.right_phalanx = Phalanx:New();
    self.right_phalanx:Init(self.right_item_phalanx, YaoQingPiPeiRightItem);

    self._right_centerOnChild = UIUtil.GetChildByName(self.right_subPanel, "UICenterOnChild", "table")
    self._right_delegate = function(go) self:_Right_OnCenterCallBack(go) end
    self._right_centerOnChild.onCenter = self._right_delegate


    self.left_item_phalanx = UIUtil.GetChildByName(self.left_subPanel, "LuaAsynPhalanx", "table");
    self.left_phalanx = Phalanx:New();
    self.left_phalanx:Init(self.left_item_phalanx, YaoQingPiPeiRightItem);

    self._left_centerOnChild = UIUtil.GetChildByName(self.left_subPanel, "UICenterOnChild", "table")
    self._left_delegate = function(go) self:_Left_OnCenterCallBack(go) end
    self._left_centerOnChild.onCenter = self._left_delegate

    self._onClickBtn_Ok = function(go) self:_OnClickBtn_Ok(self) end
    UIUtil.GetComponent(self.btn_ok, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_Ok);


    MessageManager.AddListener(YaoQingPiPeiItem, YaoQingPiPeiItem.MESSAGE_YAOQINGPIPEIITEM_SELECTED_CHANGE, YaoQingPiPeiRightControll.ItemSelectHandler, self);

    MessageManager.AddListener(YaoQingPiPeiTypeItem, YaoQingPiPeiTypeItem.MESSAGE_YAOQINGPIPEITYPEITEM_SELECTED_CHANGE, YaoQingPiPeiRightControll.TypeItemSelectHandler, self);

    self.lvSelecFat.gameObject:SetActive(false);
    self.autoPiPeiCheckBox.value = true;

    self.timeTxt.text = "";
    self.numTxt.text = "";

end


function YaoQingPiPeiRightControll:_Right_OnCenterCallBack(go)
    if (go) then
        if (self._right_currentGo == go) then
            return
        end
        self._right_currentGo = go

        self.curr_right_select_index = self.right_phalanx:GetItemIndex(go);
        self.max_lv = self.numList[self.curr_right_select_index].num;

    end
end

function YaoQingPiPeiRightControll:_Left_OnCenterCallBack(go)
    if (go) then
        if (self._left_currentGo == go) then
            return
        end
        self._left_currentGo = go

        self.curr_left_select_index = self.left_phalanx:GetItemIndex(go);
        self.min_lv = self.numList[self.curr_left_select_index].num;

    end
end

function YaoQingPiPeiRightControll:_OnClickBtn_Ok()


    YaoQingPiPeiRightControll.SetPiPeiInfos(self.data, self.min_lv, self.max_lv, self.autoPiPeiCheckBox.value);


    ModuleManager.SendNotification(FriendNotes.CLOSE_YAOQINGPIPEIPANEL);
end

function YaoQingPiPeiRightControll.SetPiPeiInfos(team_match_data, min_lv, max_lv, isAutoPiPei)

    local data = { };
    data.team_match_data = team_match_data;
    data.min_lv = min_lv;
    data.max_lv = max_lv;
    data.isAutoPiPei = isAutoPiPei;

    if data.team_match_data ~= nil and data.min_lv ~= nil then
        if data.min_lv > data.max_lv then
            data.min_lv = min_lv;
            data.max_lv = max_lv;
        end
        -- 是否马上匹配

        MessageManager.Dispatch(YaoQingPiPeiRightControll, YaoQingPiPeiRightControll.MESSAGE_YAOQINGPIPEIRIGHTCONTROLL_SELECTED_COMPLETE, data);

    end


end

--[[
10:52:34.600-187: --id= [16]
--type_name= [伏蛟山-宝石]
--min_level= [35]
drop--1= [4_1]
|    --2= [9_1]
--desc= [大王叫我来巡山呐！]
--down_float= [15]
--icon_id= [fuben_02]
--max_level= [100]
--type= [4]
--up_float= [10]
--name= [伏蛟山-35级]
--activity_id= [29]
]]
function YaoQingPiPeiRightControll:ItemSelectHandler(target)

    self.data = target.data;

    local me = HeroController:GetInstance();
    local heroInfo = me.info;
    local my_lv = heroInfo.level;

    local up_float = self.data.up_float;
    local down_float = self.data.down_float;
    local min_level = self.data.min_level;
    local max_level = self.data.max_level;
    local activity_id = self.data.activity_id;

    local selectInfo = target.selectInfo;

    my_lv = math.ceil(my_lv / 10) * 10;
    -- 需要取整

    min_level = math.floor(min_level / 10) * 10;

    local left_lv = my_lv - down_float;
    local right_lv = my_lv + up_float;

    if left_lv < min_level then
        left_lv = min_level;
    end

    if right_lv > max_level then
        right_lv = max_level;
    end

    if selectInfo ~= nil then
        left_lv = selectInfo.min_lv;
        right_lv = selectInfo.max_lv;
    end

    local numList = { };
    local sept = 10;
    local t_num = math.floor(max_level / sept);

    local curr_num = min_level;
    local index = 1;

    local left_selectIndex = 0;
    local right_selectIndex = 0;

    for i = 1, t_num do

        if curr_num <= max_level then
            numList[index] = { num = curr_num };

            if left_selectIndex == 0 and left_lv == curr_num then
                left_selectIndex = index;
            end

            if right_selectIndex == 0 and right_lv == curr_num then
                right_selectIndex = index;
            end

            curr_num = curr_num + sept;
            index = index + 1;
        end
    end

    t_num = table.getn(numList);

    self.numList = numList;

    self.right_phalanx:Build(t_num, 1, numList);
    self.left_phalanx:Build(t_num, 1, numList);

    self.lvSelecFat.gameObject:SetActive(true);

    ------------- 需要选择最佳位置 -----------------
    if left_selectIndex == 0 then
        left_selectIndex = 1;
    end

    if right_selectIndex == 0 then
        right_selectIndex = 1;
    end


    local tf = self.right_phalanx:GetItem(right_selectIndex).gameObject.transform;
    self._right_centerOnChild:CenterOn(tf);

    local tf = self.left_phalanx:GetItem(left_selectIndex).gameObject.transform;
    self._left_centerOnChild:CenterOn(tf);

end


function YaoQingPiPeiRightControll:TypeItemSelectHandler(data)

    -- {team_match_data=self.data,activityCf=self.activityCf,active_ft_data=self.active_ft_data}
    local team_match_data = data.team_match_data;
    local activityCf = data.activityCf;
    local active_ft_data = data.active_ft_data;

    -- self.timeTxt.text = LanguageMgr.Get("Friend/YaoQingPiPeiRightControll/label1",{n=activityCf.active_time[1]});
    self.timeTxt.text = LanguageMgr.Get("Friend/YaoQingPiPeiRightControll/label1");

    if active_ft_data == nil then
        active_ft_data = { };
        active_ft_data.ft = 0;
    end

    local interface_id = activityCf.interface_id;

    local buy_num = ActivityDataManager.Get_buy_num(interface_id)


    local fb_max_t = activityCf.activity_times + buy_num;

    self.numTxt.text = LanguageMgr.Get("Friend/YaoQingPiPeiRightControll/label2", { a = active_ft_data.ft, b = fb_max_t });

end


function YaoQingPiPeiRightControll:Dispose()

    MessageManager.RemoveListener(YaoQingPiPeiItem, YaoQingPiPeiItem.MESSAGE_YAOQINGPIPEIITEM_SELECTED_CHANGE, YaoQingPiPeiRightControll.ItemSelectHandler);
    MessageManager.RemoveListener(YaoQingPiPeiTypeItem, YaoQingPiPeiTypeItem.MESSAGE_YAOQINGPIPEITYPEITEM_SELECTED_CHANGE, YaoQingPiPeiRightControll.TypeItemSelectHandler);

    UIUtil.GetComponent(self.btn_ok, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_Ok = nil;

    self.right_phalanx:Dispose();
    self.right_phalanx = nil;

    self.left_phalanx:Dispose();
    self.left_phalanx = nil;

    YaoQingPiPeiRightItem.currSelect = nil;

    self._right_delegate = nil;
    if self._right_centerOnChild and self._right_centerOnChild.onCenter then
        self._right_centerOnChild.onCenter:Destroy();
    end
    self._left_delegate = nil;
    if self._left_centerOnChild and self._left_centerOnChild.onCenter then
        self._left_centerOnChild.onCenter:Destroy();
    end

end