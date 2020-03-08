Activity.ThirdAnniversaryCelebration = Activity.ThirdAnniversaryCelebration or {}
local tbAct = Activity.ThirdAnniversaryCelebration;

local RepresentMgr = luanet.import_type("RepresentMgr");

function tbAct:OnMapLoaded(nMapTemplateId)
	if Activity:__IsActInProcessByType("ThirdAnniversaryCelebration") ~= true then
		return;
	end
	if nMapTemplateId == 15 then
		self:OnEnterLinAnMap()
	end
	if nMapTemplateId == 10 then
		self:OnEnterXiangYangMap()
	end
end

function tbAct:OnEnterLinAnMap()
	RepresentMgr.SetSceneObjActive("cj_linan_chunjie", true);
	RepresentMgr.SetSceneObjActive("cj_linan_jiehun01", true);
	RepresentMgr.SetSceneObjActive("cj_linan_chunjie/cj_linan_jieri04", false);
	RepresentMgr.SetSceneObjActive("cj_linan_chunjie/cj_linan_jieri04 (1)", false);
	RepresentMgr.SetSceneObjActive("cj_linan_chunjie/cj_linan_jieri07", false);
	RepresentMgr.SetSceneObjActive("cj_linan_chunjie/cj_linan_jieri07 (1)", false);
	RepresentMgr.SetSceneObjActive("cj_linan_chunjie/cj_linan_jieri07 (2)", false);
	RepresentMgr.SetSceneObjActive("cj_linan_chunjie/cj_linan_jieri07 (3)", false);
	RepresentMgr.SetSceneObjActive("cj_linan_chunjie/cj_linan_jieri07 (4)", false);
	RepresentMgr.SetSceneObjActive("cj_linan_chunjie/cj_linan_jieri07 (5)", false);
	RepresentMgr.SetSceneObjActive("cj_linan_chunjie/cj_linan_jieri08", false);
	RepresentMgr.SetSceneObjActive("cj_linan_chunjie/cj_linan_jieri09", false);
	RepresentMgr.SetSceneObjActive("cj_linan_chunjie/cj_linan_jieri09 (1)", false);
	RepresentMgr.SetSceneObjActive("cj_linan_chunjie/cj_linan_jieri09 (2)", false);
	RepresentMgr.SetSceneObjActive("cj_linan_chunjie/cj_linan_jieri09 (3)", false);
	RepresentMgr.SetSceneObjActive("cj_linan_chunjie/cj_linan_jieri09 (4)", false);
	RepresentMgr.SetSceneObjActive("cj_linan_chunjie/cj_linan_jieri09 (5)", false);
	RepresentMgr.SetSceneObjActive("cj_linan_chunjie/cj_linan_jieri09 (6)", false);
	RepresentMgr.SetSceneObjActive("cj_linan_chunjie/cj_linan_jieri09 (7)", false);
	RepresentMgr.SetSceneObjActive("cj_linan_chunjie/cj_linan_jieri10", false);
	RepresentMgr.SetSceneObjActive("cj_linan_chunjie/cj_linan_jieri10 (1)", false);
	RepresentMgr.SetSceneObjActive("cj_linan_chunjie/cj_linan_jieri10 (2)", false);
	RepresentMgr.SetSceneObjActive("cj_linan_chunjie/cj_linan_jieri10 (3)", false);
	RepresentMgr.SetSceneObjActive("cj_linan_chunjie/cj_linan_jieri10 (4)", false);
	RepresentMgr.SetSceneObjActive("cj_linan_chunjie/cj_linan_jieri10 (5)", false);
	RepresentMgr.SetSceneObjActive("cj_linan_chunjie/cj_linan_jieri10 (6)", false);
	RepresentMgr.SetSceneObjActive("cj_linan_chunjie/cj_linan_jieri10 (7)", false);
	RepresentMgr.SetSceneObjActive("cj_linan_chunjie/cj_linan_jieri11", false);
end

function tbAct:OnEnterXiangYangMap()
	RepresentMgr.SetSceneObjActive("Jr_zhuangshi01", true);
	RepresentMgr.SetSceneObjActive("jiehunfengfu01", true);
	RepresentMgr.SetSceneObjActive("Jr_zhuangshi01/Jr_shizitou01", false);
	RepresentMgr.SetSceneObjActive("Jr_zhuangshi01/Jr_yu01", false);
	RepresentMgr.SetSceneObjActive("Jr_zhuangshi01/Jr_yu01 (1)", false);
	RepresentMgr.SetSceneObjActive("Jr_zhuangshi01/Jr_yu01 (2)", false);
	RepresentMgr.SetSceneObjActive("Jr_zhuangshi01/Jr_yu01 (3)", false);
	RepresentMgr.SetSceneObjActive("jiehunfengfu01/cj_luoyang_jiehunfengfu04", false);
	RepresentMgr.SetSceneObjActive("Jr_zhuangshi01/Jr_zhuangshi01_02", false)
	RepresentMgr.SetSceneObjActive("Jr_zhuangshi01/Jr_zhuangshi01_03", false);
	RepresentMgr.SetSceneObjActive("Jr_zhuangshi01/Jr_zhuangshi01_04", false);
end