--[[
跨服战场，排行榜
wangshuai
]]

_G.UIInteSSRanklist = BaseUI:new("UIInteSSRanklist");



function UIInteSSRanklist:Create()
	self:AddSWF("interSerSceneRanklist.swf",true,"interserver")
end;

function UIInteSSRanklist:OnLoaded(objSwf)
	objSwf.skill_btn.click = function() self:OnBtnCLick(1)end;
	objSwf.beSkill_btn.click = function() self:OnBtnCLick(2)end;
	objSwf.closeBtn.click = function() self:Hide() end;
end;

function UIInteSSRanklist:OnShow()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	self.curBtnIndex = 1;
	objSwf.skill_btn.selected = true;
	self:OnBtnCLick(self.curBtnIndex)
	self:UpdataList();
	InterSerSceneController:ReqInterSSQuesRankInfo(self.curBtnIndex)
end;

function UIInteSSRanklist:OnHide()
end;

function UIInteSSRanklist:OnBtnCLick(i)
	self.curBtnIndex = i;
	InterSerSceneController:ReqInterSSQuesRankInfo(i)
	if i == 1 then 
		self.objSwf.txt.htmlText = StrConfig['interServiceDungeon453']
	elseif i == 2 then 
		self.objSwf.txt.htmlText = StrConfig['interServiceDungeon454']
	end;
end;

UIInteSSRanklist.curBtnIndex = 1;

function UIInteSSRanklist:UpdataList()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	local list = {};

	if self.curBtnIndex == 1 then 
		list = InterSerSceneModel:GetSkillRankList()
	elseif self.curBtnIndex == 2 then 
		list = InterSerSceneModel:GetBeSkillRanklist()
	end;

	local uidata = {}
	for i,info in ipairs(list) do 
		local vo = {};
		vo.rank = i;
		vo.name = info.roleName;
		vo.addNum = info.num;
		table.push(uidata,UIData.encode(vo));
	end;

	objSwf.list.dataProvider:cleanUp();
	objSwf.list.dataProvider:push(unpack(uidata));
	objSwf.list:invalidateData();



end;

function UIInteSSRanklist:ESCHide()
	return true;
end;