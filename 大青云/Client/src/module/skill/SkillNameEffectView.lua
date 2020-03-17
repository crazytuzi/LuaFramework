--[[
技能飘字
ly
]]

_G.UISkillNameEffect = BaseUI:new("UISkillNameEffect");
UISkillNameEffect.EffectNamePrefix = "SkillNameEffect"
UISkillNameEffect.UP = "Up"
UISkillNameEffect.Left = "Left"
UISkillNameEffect.Right = "Right"

function UISkillNameEffect:Create()
	self:AddSWF("skillNameEffect.swf",true,"bottom");
end

function UISkillNameEffect:OnLoaded(objSwf)
	
end

function UISkillNameEffect:OnResize(wWidth,wHeight)
	local objSwf = self.objSwf;
	if not objSwf then return; end
end

--显示技能飘字
function UISkillNameEffect:ShowSkillNameEffect(skillId)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	local skillConfig = t_passiveskill[skillId] or t_skill[skillId]
    if not skillConfig then
        return
    end
    local pfx = skillConfig.name_pfx
	local linkName = ""
	local imgName = ""
    if pfx and pfx ~= "" then
        local pfxTable = GetPoundTable(pfx)
        local pfxFile = pfxTable[1]
        local imgFile = pfxTable[2]
        if pfxFile and pfxFile ~= "" and imgFile and imgFile ~= "" then
			if pfxFile == UISkillNameEffect.UP or pfxFile == UISkillNameEffect.Right or pfxFile == UISkillNameEffect.Left then
				linkName = UISkillNameEffect.EffectNamePrefix..pfxFile
				imgName = imgFile
			end
        end
    end
	
	if linkName == "" or imgName == "" then
		return
	end
	
	local depth = objSwf:getNextHighestDepth();
	local mc = objSwf:attachMovie(linkName,self:GetMcName(),depth);
	mc:gotoAndStop(1);
	mc._visible = false;
	mc.playOver = function(e)
		mc.playOver = nil;
		mc.effect.nameLoader.source = nil
		mc:removeMovieClip();
		mc = nil
	end
	local func = function()
		FPrint('img://resfile/skillicon/'..imgName)
		mc.effect.nameLoader.source = 'img://resfile/skillicon/'..imgName
		mc._visible = true;
		mc:play();
	end
	--
	if mc.initialized then
		func();
	else
		mc.init = function()
			func();
		end
	end
end

UISkillNameEffect.mcIndex = 0;
function UISkillNameEffect:GetMcName()
	self.mcIndex = self.mcIndex + 1;
	return self.mcIndex;
end