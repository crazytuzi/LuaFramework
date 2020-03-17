--
-- Created by IntelliJ IDEA.
-- User: Stefan
-- Date: 2014/8/13
-- Time: 21:44
-- 
--
_G.classlist['Assets'] = 'Assets'
_G.Assets = {};
_G.Assets.objName = 'Assets'
function Assets:Create()
    --add all sub folders
    self:AddPath( "resfile\\effect" );
    self:AddPath( "resfile\\model\\player" );
    self:AddPath( "resfile\\model\\npc" );
    self:AddPath( "resfile\\model\\mount" );
	self:AddPath( "resfile\\model\\godskill" );
	self:AddPath( "resfile\\model\\binghun" );
    self:AddPath( "resfile\\model\\equip" );
    self:AddPath( "resfile\\model\\drop");
	self:AddPath( "resfile\\model\\zhenbaoge");
    self:AddPath( "resfile\\model\\wuhun");
	self:AddPath( "resfile\\model\\shenbing");
	self:AddPath( "resfile\\model\\lingqi");
	self:AddPath( "resfile\\model\\mingyu");
    self:AddPath( "resfile\\model\\arena");
	self:AddPath( "resfile\\model\\lingshou");
	self:AddPath( "resfile\\model\\pet");
	self:AddPath( "resfile\\model\\julingwan");
    self:AddPath( "resfile\\model\\wing");
    self:AddPath( "resfile\\model\\worldboss");
	self:AddPath( "resfile\\model\\ui");
	self:AddPath( "resfile\\model\\neweq");
    self:AddPath( "resfile\\model\\fashions");
	self:AddPath( "resfile\\model\\vip");
	self:AddPath( "resfile\\model\\shouchong");
    self:AddPath( "resfile\\scn" );
    self:AddPath( "resfile\\scn\\Action");

    self:AddPath( "resfile\\scn\\BH" );
    self:AddPath( "resfile\\scn\\CLMC");
    self:AddPath( "resfile\\scn\\denglu");
    self:AddPath( "resfile\\scn\\JY");
    self:AddPath( "resfile\\scn\\LGDK");
    self:AddPath( "resfile\\scn\\SXG");
    self:AddPath( "resfile\\scn\\TCMJ");
    self:AddPath( "resfile\\scn\\YHZyh" );
    self:AddPath( "resfile\\scn\\ZC" );
    self:AddPath( "resfile\\scn\\BPZC");
	self:AddPath( "resfile\\scn\\BLY");
	self:AddPath( "resfile\\scn\\CJ");
	self:AddPath( "resfile\\scn\\YJ");
	self:AddPath( "resfile\\scn\\SL");
    self:AddPath( "resfile\\swf" );
    self:AddPath( "resfile\\sound" );
    self:AddPath( "resfile\\piantou" );
    self:AddPath( "resfile\\itemicon")
    self:AddPath( "resfile\\icon")
    self:AddPath( "resfile\\icon\\jingjie")
    self:AddPath( "resfile\\icon\\beicangjie")
    self:AddPath( "resfile\\icon\\v_zhuanzhi")
    self:AddPath( "resfile\\icon\\v_tianshen")
    self:AddPath( "resfile\\icon\\v_bianshen")
    self:AddPath( "resfile\\icon\\npc")
	self:AddPath( "resfile\\cameramov")
    self:AddPath( "resfile\\ui\\Icon")
	self:AddPath( "resfile\\liuguang")
	self:AddPath( "resfile\\model\\business")
    self:AddPath( "resfile\\shr")
    self:AddPath( "resfile\\model\\zongmen");
    self:AddPath( "resfile\\model\\tipsmodel");
	self:AddPath( "resfile\\model\\ridewar" );
	self:AddPath( "resfile\\model\\shenwu" );
	self:AddPath( "resfile\\model\\fabao" );
    self:AddPath( "resfile\\model\\xingtu" );
    self:AddPath( "resfile\\model\\vip" );
    self:AddPath( "resfile\\model\\xianjie");
    self:AddPath( "resfile\\model\\shenlu");
    self:AddPath( "resfile\\model\\mubiao");
	self:AddPath( "resfile\\model\\bianshen");
    self:AddPath( "resfile\\num" );
    self:AddPath( "resfile\\model\\questdungeon")
    self:AddPath( "resfile\\model\\zhuanzhi")
    self:AddPath( "resfile")

    --SkipFontConfig:CreateConfigNum();
	self:CreateConfigNum()
    return true;
end;

function Assets:CreateConfigNum()
	for i,sInfo in pairs(SkipFontConfig) do
		if type(sInfo) == "table" and sInfo.Num then 
			sInfo:NetNumFunc(); 
		end;
	end; 
end;

function Assets:AddPath(szPath)
    _sys:addPath(szPath);
end;

function Assets:GetPartRes(id, prof)
    local vo = t_equip[id]
	if vo then
		return vo['vmesh' .. prof]
	end
end

function Assets:GetPartResId(id, prof)
	local vo = t_equip[id]
	if vo then
		return vo['vmesh' .. prof]
	end
	return 0;
end

function Assets:GetEquipPfx(id, prof)
    local vo = t_equip[id]
    if vo then
        return vo["pfxname" .. prof], vo["bone" .. prof]
    end
end

function Assets:GetBinghunPartRes(id, prof)
    local vo = t_binghun[id]
    if vo then
        return vo['vmesh' .. prof]
    end
end

function Assets:GetBinghunEquipPfx(id, prof)
    local vo = t_binghun[id]
    if vo then
        return vo["pfxname" .. prof], vo["bone" .. prof]
    end
end

function Assets:GetQizhanPartRes(id, prof)
    local vo = t_ridewar[id]
    if vo then
        return vo['vmesh' .. prof]
    end
end

function Assets:GetQizhanEquipPfx(id, prof)
    local vo = t_ridewar[id]
    if vo then
        return vo["pfxname" .. prof], vo["bone" .. prof]
    end
end

function Assets:GetNpcMesh(meshId)
    if not meshId or meshId == "" then
        --Debug("Assets:GetNpcMesh Get Npc Mesh  ....", meshId)
        return
    end
    return meshId
end;

function Assets:GetNpcSkl(sklId)
    if not sklId or sklId == "" then
        --Debug("Assets:GetNpcSkl Get Npc SKL  ....", sklId)
        return
    end
    return sklId
end;

function Assets:GetNpcAnima(animaId)
    if not animaId or animaId == "" then
        --Debug("Assets:GetNpcAnima Get Npc ANIMA  ....", animaId)
        return
    end
    return animaId
end;

function Assets:GetRolePanelSen(prof)
	local sen = "v_panel_role_"..prof..".sen";
    return sen
end


