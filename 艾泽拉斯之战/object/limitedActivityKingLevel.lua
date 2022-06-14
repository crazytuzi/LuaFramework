limitedActivityKingLevel = class("limitedActivityKingLevel", limitedActivityBase);

function limitedActivityKingLevel:isTaskComplete()
	-- 国王等级 悟    空 源 码 网 ww w . w k ym w .com
	
	return dataManager.playerData:getLevel() >= self.config.params[1];
	
end

-- 是否显示前往按钮
function limitedActivityKingLevel:isShowGotoButton()
	return false;
end

