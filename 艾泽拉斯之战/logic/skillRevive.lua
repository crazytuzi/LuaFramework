local skill_base = include("skillbase")
local skillRevive = class("skillRevive",skill_base)

function skillRevive:ctor(id)
	skillRevive.super.ctor(self,id)	
	self.startEd = false
end
--[[
function skillRevive:initPosition()
	
	local casterIsKing =  iskindof(cropsUnit,"kingClass")
	if(false == casterIsKing)then	  ---不是国王复活就不管了
		return 
	end
	
	-- 设置国王的位置,从表格读取
	if self.caster then
		local data = dataConfig.configs.magicConfig[self.skillId].casterPosition;
		local position = LORD.Vector3(data[1],data[2],data[3]);

		if #self.targets > 0 then
				local targetPos = sceneManager.battlePlayer():getWorldPostion( self.targets.x,  self.targets.y);
				position = targetPos + position;				
				sceneManager.battlePlayer().targetNull:getActor():SetPosition(targetPos);				
		end				
		local skilltype = dataConfig.configs.magicConfig[self.skillId].targetType;
		-- 全屏以中心为目标
		if skilltype == enum.MAGIC_TARGET_TYPE.MAGIC_TARGET_TYPE_NONE then
			sceneManager.battlePlayer().targetNull:getActor():SetPosition(battlePrepareScene.centerPosition);
		end
		
		--print("magic_DAMAGE position x  "..position.x.."  y  "..position.y.."  z  "..position.z);
		self.caster:getActor():SetPosition(position);
				
	end
end
]]--
function skillRevive:enterStart()
	sceneManager.battlePlayer():reviveTarget(self.targets)	
 	self.startEd = true
end

function skillRevive:OnTick(dt)
	local res = true	
		if(self.startEd == true)then	
			res =  sceneManager.battlePlayer().m_AllCrops[self.targets.target]:IsActionFinish()		
		else
			res = false
		end			
	return res

end
return skillRevive