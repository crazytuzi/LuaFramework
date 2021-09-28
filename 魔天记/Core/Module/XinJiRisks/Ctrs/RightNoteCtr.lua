
local AnswerItem = require "Core.Module.XinJiRisks.Ctrs.AnswerItem"

local RightNoteCtr = class("RightNoteCtr")


function RightNoteCtr:New(transform)
    self = { };
    setmetatable(self, { __index = RightNoteCtr });
    self:Init(transform)
    return self;
end

function RightNoteCtr:Init(transform)
    self.transform = transform;
    local txts = UIUtil.GetComponentsInChildren(self.transform, "UILabel");

    self._txt_currnum = UIUtil.GetChildInComponents(txts, "txt_currnum");
    self._txt_ask = UIUtil.GetChildInComponents(txts, "txt_ask");
    self._txt_answerTip = UIUtil.GetChildInComponents(txts, "txt_answerTip");
    self.txt_elsetTime = UIUtil.GetChildInComponents(txts, "txt_elsetTime");

    self.answerItems = UIUtil.GetChildByName(self.transform, "Transform", "answerItems");
    self.title = UIUtil.GetChildByName(self.transform, "Transform", "title");
    self.endView = UIUtil.GetChildByName(self.transform, "Transform", "endView");

    self.txt_getExp1 = UIUtil.GetChildInComponents(txts, "txt_getExp1");
    self.txt_getGold1 = UIUtil.GetChildInComponents(txts, "txt_getGold1");
    self.txt_winPc1 = UIUtil.GetChildInComponents(txts, "txt_winPc1");
    self.txt_myWinRank1 = UIUtil.GetChildInComponents(txts, "txt_myWinRank1");

    self.answer_num = 4;
    self.answerItemsCtr = { };
    for i = 1, self.answer_num do
        local item = UIUtil.GetChildByName(self.answerItems, "Transform", "item" .. i);
        self.answerItemsCtr[i] = AnswerItem:New(item, self);
    end

    self.endView.gameObject:SetActive(false);
    self.hasAnswer = false;
    self.waitForClose = false;
    self:SetAnswerItemsActive(true);
end

function RightNoteCtr:ShowEnd()

    self.title.gameObject:SetActive(false);
    self._txt_ask.gameObject:SetActive(false);
    self.answerItems.gameObject:SetActive(false);
    self.txt_elsetTime.gameObject:SetActive(false);
    -- 真理总是掌握在少数人手中
    self.endView.gameObject:SetActive(true);

    self.txt_myWinRank1.text = LanguageMgr.Get("XinJiRisks/LeftNoteCtr/label5", { n = self.data.br })
    self.txt_getExp1.text = LanguageMgr.Get("XinJiRisks/LeftNoteCtr/label2", { n = self.data.exp })
    self.txt_getGold1.text = LanguageMgr.Get("XinJiRisks/LeftNoteCtr/label3", { n = self.data.money })

    self.txt_winPc1.text = LanguageMgr.Get("XinJiRisks/LeftNoteCtr/label6", { n = self.data.wr })

end

function RightNoteCtr:SetAnswerItemsActive(v)
    self.answerItems.gameObject:SetActive(v);
    self.txt_elsetTime.gameObject:SetActive(not v);
end

function RightNoteCtr:SetElseTime(sec)
    self:SetAnswerItemsActive(false);
    self.elseTime = sec;

    self.txt_elsetTime.text = tostring(self.elseTime);

    if (self._timer) then
        self._timer:Stop()
        self._timer = nil
    end

    self._timer = Timer.New( function()
        self.elseTime = self.elseTime - 1;
        self.txt_elsetTime.text = tostring(self.elseTime);

        if self.elseTime == -1 then

            self._timer:Stop()
            self._timer = nil
            self:SetAnswerItemsActive(true);
            XinJiRisksProxy.Try_XinJiRisksGetCurrState();
        end

    end , 1, self.elseTime + 2, false);
    self._timer:Start();

end

--[[
输出：
idx：第几题
qId：题库id
rc：答对数量
st：阶段 1-5
rs：下一阶段倒计时（秒）
ap：[Int,]答案支持率
ar：正确答案1-4

wr：胜率
br：领先率
exp：累计经验
money：累计金钱
]]
function RightNoteCtr:SetData(data)
    local qId = data.qId;
    local ap = data.ap;

    self.data = data;

    if self.idx ~= data.idx then
        for i = 1, self.answer_num do
            self.answerItemsCtr[i]:SetMyAnswer(false)
        end
        self.hasAnswer = false;
    end

    self.idx = data.idx;

    -- self.idx=10;
    -- self:SetState(5, 10);

    if qId == 0 then
        return;
    end

    self.effort = ConfigManager.GetEffort(qId);

    self._txt_currnum.text = data.idx .. "/10";
    self._txt_ask.text = self.effort.question;

    self.min_ap = 100;
    for i = 1, self.answer_num do
        if self.min_ap > ap[i] then
            self.min_ap = ap[i];
        end
    end

    for i = 1, self.answer_num do
        self.answerItemsCtr[i]:SetAnswer(self.effort["answer" .. i], i);
        self.answerItemsCtr[i]:SetAp(ap[i]);
        self.answerItemsCtr[i]:SetZcbg(false);
        if i == data.ar then
            self.answerItemsCtr[i]:SetAr(true);
        else
            self.answerItemsCtr[i]:SetAr(false);
        end
    end

    local rs = math.floor(data.rs);
    local st = data.st;

    self.hasAnswer = false;
    self:SetState(st, rs);



end



function RightNoteCtr:SetState(st, rs)

    if (st == 1 or st == 3) and self.hasAnswer then
        self._txt_answerTip.text = LanguageMgr.Get("XinJiRisks/RightNoteCtr/label" .. st .. "_hasAnswer", { n = rs });
    else
        self._txt_answerTip.text = LanguageMgr.Get("XinJiRisks/RightNoteCtr/label" .. st, { n = rs });
    end



    if (self._timer) then
        self._timer:Stop()
        self._timer = nil
    end
    self.rs = rs;
    if rs > 0 then
        self._timer = Timer.New( function()
            self.rs = self.rs - 1;


            if (st == 1 or st == 3) and self.hasAnswer then
                self._txt_answerTip.text = LanguageMgr.Get("XinJiRisks/RightNoteCtr/label" .. st .. "_hasAnswer", { n = self.rs });
            else
                self._txt_answerTip.text = LanguageMgr.Get("XinJiRisks/RightNoteCtr/label" .. st, { n = self.rs });
            end

            if self.idx == 10 and st == 5 then
                self:UpCloseTime()
            end

        end , 1, rs, false);
        self._timer:Start();
    end


    for i = 1, self.answer_num do
        self.answerItemsCtr[i]:UpSt(st,self.min_ap)
    end



end

function RightNoteCtr:UpCloseTime(st, rs)


    self.waitForClose = true;

    self.closeTime = 10;
    self._txt_answerTip.text = LanguageMgr.Get("XinJiRisks/RightNoteCtr/label6", { n = self.closeTime });

    if (self._timer) then
        self._timer:Stop();
        self._timer = nil
    end

    self._timer = Timer.New( function()
        self.closeTime = self.closeTime - 1;
        self._txt_answerTip.text = LanguageMgr.Get("XinJiRisks/RightNoteCtr/label6", { n = self.closeTime });

        if self.closeTime == 0 then
            self:ShowEndTime()
        end

    end , 1, self.closeTime, false);
    self._timer:Start();


end

function RightNoteCtr:ShowEndTime()
    self.waitForClose = true;

    self:ShowEnd();
    self.closeTime = 10;
    self._txt_answerTip.text = LanguageMgr.Get("XinJiRisks/RightNoteCtr/label6", { n = self.closeTime });

    if (self._timer) then
        self._timer:Stop()
        self._timer = nil
    end

    self._timer = Timer.New( function()
        self.closeTime = self.closeTime - 1;
        self._txt_answerTip.text = LanguageMgr.Get("XinJiRisks/RightNoteCtr/label6", { n = self.closeTime });

        if self.closeTime == 0 then
            ModuleManager.SendNotification(XinJiRisksNotes.CLOSE_XINJIRISKSPANEL);
        end

    end , 1, self.closeTime, false);
    self._timer:Start();
end



--[[
52 回答问题
输入：
a：回答答案1-4
输出：
a：回答答案1-4

]]
function RightNoteCtr:SetMyAnswer(a)

    self.hasAnswer = true;
    -- 需要锁柱答案
    for i = 1, self.answer_num do
        self.answerItemsCtr[i]:SetMyAnswer(a == i)
    end



end

function RightNoteCtr:Dispose()

    for i = 1, self.answer_num do
        self.answerItemsCtr[i]:Dispose();
    end

    if (self._timer) then
        self._timer:Stop()
        self._timer = nil
    end

    self.answerItemsCtr = nil;
    self.transform = nil;
    self._txt_currnum = nil;
    self._txt_ask = nil;
    self._txt_answerTip = nil;

end


return RightNoteCtr;