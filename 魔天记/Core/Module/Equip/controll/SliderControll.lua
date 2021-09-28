
require "Core.Module.Common.EnterFrameRun"

SliderControll = { };

function SliderControll:New()
    local o = { };
    setmetatable(o, { __index = self });
    return o;
end

function SliderControll:Init(gameObject, max_w)
    -- 280

    self.gameObject = gameObject
    self.max_w = max_w;

    self.max_slidercontenpr_w = 305;

    self.slidercontenpr = UIUtil.GetChildByName(self.gameObject, "UISprite", "slidercontenpr");
    -- 预填充进度
    self.sliderconten = UIUtil.GetChildByName(self.gameObject, "UISprite", "sliderconten");
    -- 基础进度

    self.expimg = UIUtil.GetChildByName(self.gameObject, "UISprite", "expimg");

    self.expTotalTxt = UIUtil.GetChildByName(self.gameObject, "UILabel", "expTotalTxt");

    ProductCostPanelItem.clickEnble = true;
    self.enterFrameRun = EnterFrameRun:New();

end

function SliderControll:TryShowEffect()

    if self.effectCtr == nil then
        self.effectCtr = UIEffect:New();
        self.effectCtr:Init(self.gameObject, self.expimg, 1, "ui_refining_1")
    end
    self.effectCtr:Play();
    self.effectCtr:SetPos(30, 0);

end

--[[


  can_to_expObj 经验升级数据    StrongExpDataManager.GetBagerExp  里面的数据结构
  info 物品信息

   upLvInfos1--extExp= [7]
|         | --parenExp= [7]
|         | --upToLv= [1]
|         | --canUpTo= [true]
|         | --dlv= [1]
|         | --baseExp= [0]
|         2--extExp= [3]
|           --parenExp= [21]
|           --upToLv= [1]
|           --canUpTo= [false]
|           --dlv= [1]
|           --baseExp= [0]
--curr_slv= [0]
--canUpLv= [true]
--curr_slv
--curr_exp
--curr_parenExp


]]
function SliderControll:SetData(can_to_expObj, info)

    self.enterFrameRun:Stop();
    self.enterFrameRun:Clean();
    self:PlayComplete()

    self.can_to_expObj = can_to_expObj;

    local canUpLv = can_to_expObj.canUpLv;
    local curr_slv = can_to_expObj.curr_slv;
    local curr_exp = can_to_expObj.curr_exp;
    local curr_parenExp = can_to_expObj.curr_parenExp;

    self:ReSetW(curr_exp, curr_parenExp)

    self.slidercontenpr.gameObject:SetActive(false);

    if canUpLv then
        local upLvInfos = can_to_expObj.upLvInfos;
        local t_num = table.getn(upLvInfos);
        local lastInfo = upLvInfos[t_num];

        if lastInfo.extExp > 0 then

            self.expTotalTxt.text = "     " .. lastInfo.baseExp .. "[00ff00](+" .. lastInfo.extExp .. ")[-]" .. "/" .. lastInfo.parenExp;
            self:PlayTeem(can_to_expObj);
        else

            self.expTotalTxt.text = "     " .. lastInfo.baseExp .. "/" .. lastInfo.parenExp;
        end

    else

        local curr_slv = can_to_expObj.curr_slv;
        if curr_slv == 100 then
            -- 设置等级上限
            curr_exp = curr_parenExp;
            self.expTotalTxt.text = "     " .. curr_exp .. "/" .. curr_parenExp;
            self:ReSetW(curr_exp, curr_parenExp)
        else
            self.expTotalTxt.text = "     " .. curr_exp .. "/" .. curr_parenExp;
        end


    end



end


function SliderControll:HideCt()
    self.slidercontenpr.gameObject:SetActive(false);
    self.sliderconten.gameObject:SetActive(false);
end


--[[
 播放 填充动画

]]
function SliderControll:PlayTeem(can_to_expObj)

    local upLvInfos = can_to_expObj.upLvInfos;
    local t_num = table.getn(upLvInfos);
    local temlist = { };
    if t_num > 4 then
        -- 如果 可以升级 次数 》4 次的话， 那么 就 取 前 1 后 4 进行 显示播放效果，

        temlist[1] = upLvInfos[1];

        temlist[2] = upLvInfos[t_num - 2];
        temlist[3] = upLvInfos[t_num - 1];
        temlist[4] = upLvInfos[t_num];

    else
        temlist = upLvInfos;
    end
    self:TryPlay(temlist)
end

function SliderControll:ReSetW(curr_exp, curr_parenExp)

    -- log("ReSetW "..curr_exp.." / "..curr_parenExp);
    local curr_pc = curr_exp / curr_parenExp;

    if curr_pc > 1 then
        curr_pc = 1;
    end


    local curr_w = self.max_w * curr_pc;

    if curr_w < 0.1 then
        self.sliderconten.gameObject:SetActive(false);
    else
        self.sliderconten.width = curr_w;
        self.sliderconten.gameObject:SetActive(true);
    end


end

--[[
 2--extExp= [3]
|           --parenExp= [21]
|           --upToLv= [1]
|           --canUpTo= [false]
|           --dlv= [1]
|           --baseExp= [0]
]]
function SliderControll:TryPlay(plist)


    self:ReSetW(self.can_to_expObj.curr_exp, self.can_to_expObj.curr_parenExp)

    local t_num = table.getn(plist);

    -- 直接显示结果

    local obj = plist[t_num];
    obj.index = 1;
    self.maxTeewnNum = 2;
    self:UpSliderW(obj);

    --[[
    self.enterFrameRun:Stop();
    self.enterFrameRun:Clean();

    self.maxTeewnNum=2;
    -- 5 -- 8
    self.expTotalTxt.gameObject:SetActive(false);
    ProductCostPanelItem.clickEnble = false;

    for i = 1, t_num do
        -- function EnterFrameRun:AddHandler(hander, hander_target, frame_num,data)
        local obj = plist[i];
        obj.index = 0;
        self.enterFrameRun:AddHandler(SliderControll.UpSliderW, self, self.maxTeewnNum, obj);


        if i ~= t_num then
            self.enterFrameRun:AddHandler(nil, nil, 10, nil);
        else
            self.enterFrameRun:AddHandler(nil, nil, 3, nil);
            self.enterFrameRun:AddHandler(SliderControll.PlayComplete, self, 1);
        end


        -- 和策划沟通后，定为直接显示最终结果
        -- http://192.168.0.8:3000/issues/1108


    end


    self.enterFrameRun:Start();
    ]]
end

function SliderControll:PlayComplete()

    self.expTotalTxt.gameObject:SetActive(true);
    ProductCostPanelItem.clickEnble = true;

end

--[[
 2--extExp= [3]
|           --parenExp= [21]
|           --upToLv= [1]
|           --canUpTo= [false]
|           --dlv= [1]
|           --baseExp= [0]
]]

function SliderControll:UpSliderW(obj)

    -- log("obj.index == " .. obj.index);

    if obj.baseExp == 0 then
        self.sliderconten.gameObject:SetActive(false);
    end

    local texp = obj.baseExp + obj.extExp;
    local pexp = obj.parenExp;



    local curr_pc = texp / pexp;

    if curr_pc > 1 then
        curr_pc = 1;
    end

    local curr_w = self.max_slidercontenpr_w * curr_pc;
    -- self.maxTeewnNum
    curr_w = curr_w *(obj.index /(self.maxTeewnNum - 1));



    if curr_w < 1 then
        self.slidercontenpr.gameObject:SetActive(false);

    else

        if curr_w > self.max_slidercontenpr_w then
            curr_w = self.max_slidercontenpr_w;
        end

        -- log("curr_w "..curr_w.."  max_w "..self.max_w);

        self.slidercontenpr.width = curr_w;
        self.slidercontenpr.gameObject:SetActive(true);

    end


    obj.index = obj.index + 1;




end

function SliderControll:Dispose()

    self.enterFrameRun:Stop();
    self.enterFrameRun:Clean()
    self.enterFrameRun = nil;

    if self.effectCtr then
        self.effectCtr:Dispose();
        self.effectCtr = nil
    end

    self.gameObject = nil;

    self.slidercontenpr = nil;
    -- 预填充进度
    self.sliderconten = nil;
    -- 基础进度

    self.expTotalTxt = nil;

end