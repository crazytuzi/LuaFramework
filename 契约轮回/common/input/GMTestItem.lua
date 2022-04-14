--
-- @Author: LaoY
-- @Date:   2019-11-21 15:54:43
--

--require("game.xx.xxx")

GMTestItem = GMTestItem or class("GMTestItem",BaseCloneItem)

function GMTestItem:ctor(obj,parent_node,layer)
	self.position = pos(0,0)
	GMTestItem.super.Load(self)
end

function GMTestItem:dctor()
	self:RemoveAction()
end

function GMTestItem:LoadCallBack()
	self.image = self.transform:GetComponent('Image')

	SetLocalScale(self.transform,2.0)
	self:AddEvent()
end

function GMTestItem:AddEvent()
end

function GMTestItem:SetData(data)

end

function GMTestItem:StartAction(pos,rateAction,rate)
	local action = cc.MoveTo(3.0,pos.x,pos.y)
	if rateAction then
		rate = rate or 2.0
		action = rateAction(action,rate)
		-- action = cc.EaseOut(action,2.0)
	else
		action = cc.EaseExponentialOut(action)
	end
	action = cc.Sequence(action,cc.CallFunc(function()
		self:destroy()
	end))
	cc.ActionManager:GetInstance():addAction(action,self)
end

function GMTestItem:RemoveAction()
	cc.ActionManager:GetInstance():removeAllActionsFromTarget(self)
end

function GMTestItem:SetPosition(x,y)
	DebugLog(string.format("cc move ===>[offX = %s,offY = %s] time = %s",self.position.x - x,self.position.y - y,Time.deltaTime))
	GMTestItem.super.SetPosition(self,x,y)
	self.position.x = x
	self.position.y = y
end

-- local DOTween = DG.Tweening.DOTween
function GMTestItem:StartDoMove(pos)
	-- local quence = DOTween.Sequence()
	-- quence:Append(self.transform:DOLocalMove(Vector3(pos.x,pos.y,0), 3.0))
	-- quence:AppendCallback(function()
	-- 	self:destroy()
	-- end)
	-- quence:play()
end