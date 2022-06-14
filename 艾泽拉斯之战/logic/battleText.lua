
battleText = {};
battleText.hitList = {};

local battleTextNormal = include("battleTextNormal");
local battleTextCommon = include("battleTextCommon");
local battleTextBuff = include("battleTextBuff");
local battleTextDebuff = include("battleTextDebuff");
local battleTextImmune = include("battleTextImmune");
local battleTextSkillName = include("battleTextSkillName");

battleText.effectTypeMap = {
	["normal"] = battleTextNormal;
	["common"] = battleTextCommon;
	["buff"] = battleTextBuff;
	["debuff"] = battleTextDebuff;
	["immune"] = battleTextImmune;
	["skill"] = battleTextSkillName;
};

function battleText.update(dt)
	
	local count = #battleText.hitList;
	local pos = 1;
	
	while pos <= count do
		local instance = battleText.hitList[pos];
		if instance:checkDelay(dt) and instance:update(dt) == true then
			table.remove(battleText.hitList, pos);
			count = #battleText.hitList;
		else
			pos = pos + 1;
		end
	end
	
end

battleText.lastAddTime = 0;
battleText.addtionalDelay = 1;

function battleText.addHitText(text, unitIndex, fontName, effectType)
	
	local delayTime = 0;
	
	local nowTime = dataManager.getServerTime();
	
	if nowTime == battleText.lastAddTime then	
		delayTime = battleText.addtionalDelay * 500;
		battleText.addtionalDelay = battleText.addtionalDelay + 1;
	else
		battleText.addtionalDelay = 1;
	end
	battleText.lastAddTime = nowTime;

	-- do add
	effectType = effectType or "common";
	
	--print("battleText.addHitText text "..text);
	local factory = battleText.effectTypeMap[effectType];
	
	if factory then
		local instance = factory.new(effectType, text, unitIndex, fontName, delayTime);
		table.insert(battleText.hitList, instance);
	end
end

function battleText.changeUnitNum(unitCountChange, unitIndex)
	if unitCountChange > 0 then
		-- 加数量
		battleText.addHitText("加"..unitCountChange, unitIndex, "corpsnum1", "normal")
	elseif unitCountChange < 0 then
		unitCountChange = -unitCountChange;
		-- 减
		battleText.addHitText("减"..unitCountChange, unitIndex, "corpsnum2", "normal")
	end
end

function battleText.handleUIWorldPos(dt)

	local count = #battleText.hitList;
	local pos = 1;
	
	while pos <= count do
		local instance = battleText.hitList[pos];
		
		--print("pos"..pos.." instance.text  "..instance.text.." pos x "..instance.pos.x.." y "..instance.pos.y);
		if instance:isplay() then
			LORD.Renderer:Instance():renderText(instance.text, instance.pos, instance.fontName, instance.color, LORD.Vector2(instance.scale, instance.scale), true);
		end
		pos = pos + 1;
	end
	
 
	local AllCrops = sceneManager.battlePlayer().m_AllCrops
	
	if AllCrops then
		for _,v in pairs (AllCrops) do
			if(v)then
				v:updateUI(dt) 
			end		
		end	
	end
 
end