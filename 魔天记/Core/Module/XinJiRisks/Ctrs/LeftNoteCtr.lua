
local LeftNoteCtr = class("LeftNoteCtr")


function LeftNoteCtr:New(transform)
    self = { };
    setmetatable(self, { __index = LeftNoteCtr });
    self:Init(transform)
    return self;
end

function LeftNoteCtr:Init(transform)
    self.transform = transform;
    local txts = UIUtil.GetComponentsInChildren(self.transform, "UILabel");

    self._txt_winPc = UIUtil.GetChildInComponents(txts, "txt_winPc");
    self._txt_myWinRank = UIUtil.GetChildInComponents(txts, "txt_myWinRank");
    self._txt_getExp = UIUtil.GetChildInComponents(txts, "txt_getExp");
    self._txt_getGold = UIUtil.GetChildInComponents(txts, "txt_getGold");
    self._txt_ggTitle = UIUtil.GetChildInComponents(txts, "txt_ggTitle");
    self._txt_gongao = UIUtil.GetChildInComponents(txts, "txt_gongao");

    self.answers = { };
    self.answers[1] = "A";
    self.answers[2] = "B";
    self.answers[3] = "C";
    self.answers[4] = "D";

    self.answerNoticeList = { };

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
function LeftNoteCtr:SetData(data)

    if data ~= nil then

        self._txt_winPc.text = data.wr .. "%";
        self._txt_myWinRank.text = LanguageMgr.Get("XinJiRisks/LeftNoteCtr/label1", { n = data.br })
        self._txt_getExp.text = LanguageMgr.Get("XinJiRisks/LeftNoteCtr/label2", { n = data.exp })
        self._txt_getGold.text = LanguageMgr.Get("XinJiRisks/LeftNoteCtr/label3", { n = data.money })



    end

end

--[[
53 答题公告栏（服务器发出）
输出：
pn：player name
a：答案1-4

]]
function LeftNoteCtr:Add_Server_notice(pn, a)
    table.insert(self.answerNoticeList, { pn = pn, a = a });
    local t_num = table.getn(self.answerNoticeList);
    local starindex = 1;

    if t_num > 3 then
        starindex = t_num - 2;
    end

    local str = "";
    for i = starindex, t_num do
        local obj = self.answerNoticeList[i];
        str = str .. LanguageMgr.Get("XinJiRisks/LeftNoteCtr/label4", { n1 = obj.pn, n2 = self.answers[obj.a] }) .. "\n";
    end

    self._txt_gongao.text = str;

end

function LeftNoteCtr:Dispose()

    self.transform = nil;
    self._txt_winPc = nil;
    self._txt_myWinRank = nil;
    self._txt_getExp = nil;
    self._txt_getGold = nil;
    self._txt_ggTitle = nil;
    self._txt_gongao = nil;

end


return LeftNoteCtr;