--[[
/*code is far away from bug with the animal protecting
    * ┏┓　 ┏┓
    *┏┛┻━━━┛┻┓
    *┃ 　　　┃ 　
    *┃ 　━ 　┃
    *┃┳┛　 ┗┳┃
    *┃ 　　　┃
    *┃ 　┻   ┃
    *┃ 　　　┃
    *┗━┓　 ┏━┛
    *　┃　 ┃神兽保佑
    *　┃　 ┃代码无BUG！
    *　┃　 ┗━━━┓
    *　┃　 　　┣┓
    *　┃　   　┏┛
    *　┗┓┓┏━┳┓┏┛
    *　 ┃┫┫ ┃┫┫
    *　 ┗┻┛ ┗┻┛
    *　　　
    */
]]
local ClimbGoalLayer = class("ClimbGoalLayer", BaseLayer);

CREATE_SCENE_FUN(ClimbGoalLayer);
CREATE_PANEL_FUN(ClimbGoalLayer);


function ClimbGoalLayer:ctor(data)
    self.super.ctor(self,data);
    
    self:init("lua.uiconfig_mango_new.climb.ClimbGoal");
end


function ClimbGoalLayer:initUI(ui)
    self.super.initUI(self,ui);

    self.btn_close         = TFDirector:getChildByPath(ui, 'btn_close');
    self.btn_tiaomu = {}
    self.btn_xuanzhong = {}

    self.img_shengli = TFDirector:getChildByPath(ui, 'img_shengli');

    for i=1,2 do
        self.btn_tiaomu[i]         = TFDirector:getChildByPath(ui, 'btn_tiaomu'..i);
        self.btn_xuanzhong[i]         = TFDirector:getChildByPath(self.btn_tiaomu[i], 'img_shengli');
        self.btn_tiaomu[i]:setTouchEnabled(false)
    end
end

function ClimbGoalLayer:onShow()
    self.super.onShow(self)
    self:refreshBaseUI()
    self:refreshUI()
end

function ClimbGoalLayer:refreshBaseUI()

end

function ClimbGoalLayer:refreshUI()
    if self.climbFloor == nil then
        return
    end
    local img_shengli2 = TFDirector:getChildByPath(self.img_shengli, 'img_shengli2');
    if ClimbManager.climbStarInfo[self.climbFloor] == nil or ClimbManager.climbStarInfo[self.climbFloor].star == 0 then
        img_shengli2:setVisible(false)
    else
        img_shengli2:setVisible(true)
    end

    local climbPassLimitConfig = ClimbPassLimitConfig:objectByID(self.climbFloor)
    if climbPassLimitConfig == nil then
        print("climbPassLimitConfig == nil , floor = ",self.climbFloor)
        return
    end
    local climbLimitList = string.split(climbPassLimitConfig.limit_id,"_")
    for i=1,2 do
        self:initOptionInfo(i,tonumber(climbLimitList[i]));
    end

end

function ClimbGoalLayer:initOptionInfo( index ,limit_id)
    local txt_shuoming = TFDirector:getChildByPath(self.btn_tiaomu[index] , 'txt_shuoming');
    local img_shengli2 = TFDirector:getChildByPath(self.btn_tiaomu[index] , 'img_shengli2');

    local options = ClimbLimitConfig:objectByID(limit_id)

    if options == nil then
        print("通关条件信息 == null ， id ==",limit_id)
        return
    end

    txt_shuoming:setText(options.show);

    if ClimbManager.climbStarInfo[self.climbFloor] == nil then
        img_shengli2:setVisible(false)
        return
    end

    local flag = bit_and(ClimbManager.climbStarInfo[self.climbFloor].passLimit,2^(index-1))
    if flag == 0 then
        img_shengli2:setVisible(false)
    else
        img_shengli2:setVisible(true)
    end
end

--填充主页信息
function ClimbGoalLayer:loadMissionInfo(mountainInfo)
    self.climbFloor = mountainInfo.id
end
--填充主页信息
function ClimbGoalLayer:loadFloor(floor)
    self.climbFloor = floor
end

function ClimbGoalLayer:removeUI()
    self.super.removeUI(self);

end

function ClimbGoalLayer:registerEvents()
    self.super.registerEvents(self);
    ADD_ALERT_CLOSE_LISTENER(self,self.btn_close)
end

function ClimbGoalLayer:removeEvents()
    self.super.removeEvents(self);

end

return ClimbGoalLayer;
