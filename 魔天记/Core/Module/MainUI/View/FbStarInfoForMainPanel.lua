


FbStarInfoForMainPanel = class("FbStarInfoForMainPanel");



--[[

]]
function FbStarInfoForMainPanel:New()
    self = { };
    setmetatable(self, { __index = FbStarInfoForMainPanel });
    return self
end

function FbStarInfoForMainPanel:SetActive(active)
    if (self.gameObject) then
        self.gameObject.gameObject:SetActive(active);
    end
end



function FbStarInfoForMainPanel:Init(transform)

    self.transform = transform;

    self.star1 = UIUtil.GetChildByName(self.transform, "UISprite", "star1");
    self.star2 = UIUtil.GetChildByName(self.transform, "UISprite", "star2");
    self.star3 = UIUtil.GetChildByName(self.transform, "UISprite", "star3");

    self.txt_dec = UIUtil.GetChildByName(self.transform, "UILabel", "txt_dec");
    self.txt_exp = UIUtil.GetChildByName(self.transform, "UILabel", "txt_exp");


    self.starAward = { };
    self.starAward[3] = 200;
    self.starAward[2] = 150;
    self.starAward[1] = 100;

    MessageManager.AddListener(MainUIProxy, MainUIProxy.MESSAGE_GETFBSTAR_CALLBACK, FbStarInfoForMainPanel.UpAwardByStar, self);


end




function FbStarInfoForMainPanel:SetData()

    if GameSceneManager.id ~= nil then
        local insCf = InstanceDataManager.GetInsByMapId(GameSceneManager.id);
        local pass_conditions = insCf.pass_conditions;
        local plen = table.getn(pass_conditions);

        self.fb_time = insCf.time * 60;
        self.insCf = insCf;

        self.conditions = { };

        for i = 1, plen do

            local condition = pass_conditions[i];
            local condition_arr = ConfigSplit(condition);
            local len = table.getn(condition_arr);

            local ct_id = tonumber(condition_arr[1]);
            local star = tonumber(condition_arr[len]);
            -- 最后一个一定是 对应的 star

            local ctobj = { };
            ctobj.star = star;
            ctobj.ct_id = ct_id;

            if ct_id == 5 then
                -- 只是通过

            elseif ct_id == 2 then
                -- 时间内 通过
                ctobj.label = "FbStarInfoForMainPanel/label1";
                ctobj.time = tonumber(condition_arr[2]);
            elseif ct_id == 17 then
                -- 怪物血量 通过
                ctobj.label = "FbStarInfoForMainPanel/label3";
                ctobj.monster_id = tonumber(condition_arr[2]);
                ctobj.monster_hp_pc = tonumber(condition_arr[3]);
                ctobj.monster_cf = ConfigManager.GetMonById(ctobj.monster_id);

            end
            self.conditions[star] = ctobj;
        end

        --

        self:UpAwardByStar(3);


        if insCf.star_notice == 1 then
            -- 需要获取最新的星际
            MainUIProxy.TryGetFBStar()
        end

    else
        log("------------------- GameSceneManager.id ~= nil --------------------------");
    end

end

local timeTranlateFun = GetTimeByStr3
function FbStarInfoForMainPanel:OnUpElseTime(fb_else_totalTime, isUpServer)

    if not self.enble or self.fb_time == nil then
        return;
    end

    if isUpServer then
        --  收到服务器信息 重设数据
        self:UpAwardByStar(3);
    end

    local hasPassTime = self.fb_time - fb_else_totalTime;
    local ctobj = self.conditions[self.curr_star];
    local ct_id = ctobj.ct_id;


    if ct_id == 5 then
        -- 只是通过
        self.txt_dec.text = LanguageMgr.Get("FbStarInfoForMainPanel/label2");
    elseif ct_id == 2 then
        -- 时间内 通过
        local dt = ctobj.time - hasPassTime;
        self.txt_dec.text = LanguageMgr.Get("FbStarInfoForMainPanel/label1", { n = timeTranlateFun(dt) });
        if dt <= 0 then
            self:UpAwardByStar(self.curr_star - 1);
            self:OnUpElseTime(fb_else_totalTime, false)
        end
    elseif ct_id == 17 then
        -- 怪物血量 通过
        self.txt_dec.text = LanguageMgr.Get("FbStarInfoForMainPanel/label3", { n = ctobj.monster_cf.name, m = ctobj.monster_hp_pc });
    end

end

function FbStarInfoForMainPanel:UpAwardByStar(star)


    if star == 0 then
        Error("Error   UpAwardByStar  star can not be 0");
        return;
    end

    self.curr_star = star;

    local panel_txt = self.insCf.panel_txt;
    local aw = panel_txt[star];
    local arr = ConfigSplit(aw);

    local str1 = LanguageMgr.Get("FbStarInfoForMainPanel/label4");
    local str2 = LanguageMgr.Get("FbStarInfoForMainPanel/label5");
   
    self.txt_exp.text = str1.."[9cff94]"..arr[2].."[-]"..arr[3]..str2;


    if star == 3 then
        self.star3.spriteName = "star1";
        self.star2.spriteName = "star1";
    elseif star == 2 then
        self.star3.spriteName = "star2";
        self.star2.spriteName = "star1";
    elseif star == 1 then
        self.star3.spriteName = "star2";
        self.star2.spriteName = "star2";
    end
end


function FbStarInfoForMainPanel:Show()
    self.enble = true;
    self.transform.gameObject:SetActive(true);


end

function FbStarInfoForMainPanel:Close()
    self.enble = false;
    self.transform.gameObject:SetActive(false);
end


function FbStarInfoForMainPanel:Dispose()

    MessageManager.RemoveListener(MainUIProxy, MainUIProxy.MESSAGE_GETFBSTAR_CALLBACK, FbStarInfoForMainPanel.UpAwardByStar);


end
