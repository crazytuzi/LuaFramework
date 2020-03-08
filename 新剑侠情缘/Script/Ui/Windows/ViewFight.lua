local ViewFight = Ui:CreateClass("ViewFight");

local NpcViewMgr = luanet.import_type("NpcViewMgr");

local SCALE = 0.5; --模型缩放
local fSpeed = 1; --动画速度

local tbPos = {
	{-369.28,	-127, 90}, --x,y,nDir
	{416.8, 		-127, -90},
}

local tbFactionActAni = 
{
    [1] = "at04"; --门派 -动作
    [2] = "at04";
    [3] = "at03";
    [4] = "at02";
}


local tbViewModelIds = {} -- {id1,id2}
local tbPlayActName = {}; ---[id1] = "szAct"

function ViewFight:HideRoles()
	for i,v in ipairs(tbViewModelIds) do
		NpcViewMgr.SetUiViewFeatureActive(v, false)
	end
	Ui:CloseWindow(self.UI_NAME)
end

function ViewFight:PlayerAniEnd()
	self.nShowCount = self.nShowCount - 1
	if self.nShowCount == 0 then
		self:HideRoles()
	end
end

function ViewFight:LoadBodyFinish(nViewId)
	local nAntiTime = NpcViewMgr.PlayAnimation(nViewId, tbPlayActName[nViewId], 0, 1, fSpeed)
	if nAntiTime ~= 0 then
		Timer:Register(math.floor( Env.GAME_FPS * nAntiTime) , function ()
			self:PlayerAniEnd();
		end)
	end
end

--直接查看到别的玩家数据的用ViewRole:OpenWindow 打开
function ViewFight:OnOpenEnd(tbEquip, tbNpcRes, tbPartnerInfo, pAsyncRole, fCallBack)
	self.fCallBack = fCallBack

	local tbViewRes = {me.GetNpcResInfo(), tbNpcRes}
	self.nShowCount = 2

	
	for i = 1, 2 do
		local bSingleNpc = false
		local nShowId = tbViewModelIds[i]
		local nX, nY, nDir = unpack(tbPos[i])
		if not nShowId then
			nShowId = NpcViewMgr.CreateUiViewFeature(nX, nY,0, 0, nDir, 0)
			tbViewModelIds[i] = nShowId
		else
			NpcViewMgr.SetUiViewFeatureActive(nShowId, true)
		end
		NpcViewMgr.SetScale(nShowId, SCALE)
		
		if i == 1 then
			tbPlayActName[nShowId] = tbFactionActAni[me.nFaction]
		else
			if pAsyncRole.GetActName then
				bSingleNpc = true
				tbPlayActName[nShowId] = pAsyncRole.GetActName()
			elseif pAsyncRole.GetFaction then
				tbPlayActName[nShowId] = tbFactionActAni[pAsyncRole.GetFaction()] 
			else
				Log(debug.traceback())
			end
		end

		local tbNpcRes = tbViewRes[i]
		assert(tbNpcRes)
		for nPartId, nResId in pairs(tbNpcRes) do
			if nPartId == 0 then
				NpcViewMgr.ChangePartBody(nShowId, nResId, bSingleNpc);
			else
				NpcViewMgr.ChangeNpcPart(nShowId, nPartId, nResId);
			end
		end
	end
end

function ViewFight:OnClose()
	if self.fCallBack then
		self.fCallBack();
		self.fCallBack = nil;
	end
end

function ViewFight:RegisterEvent()
    return
    {
        { UiNotify.emNOTIFY_LOAD_RES_FINISH,           self.LoadBodyFinish},
    };
end
