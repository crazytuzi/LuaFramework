PoolMgr = {}
local this = PoolMgr

PoolMgr.PlayerType=1
PoolMgr.MonsterType=4
PoolMgr.CollectType=5
PoolMgr.DropType=6
PoolMgr.WeaponType=2
PoolMgr.WingType=3

function HidePoolObj( show, go )
	if not show then
		if not ToLuaIsNull(go) then
			Util.SetLocalPosition(go,-10000,-10000,-10000)
		end
	end
end


function PoolMgr.Init()
	this.poolPerTypeMax =10
	this.isClear = false
	this.pool = { -- 缓存池的
		{}, -- 1 players
		{}, -- 2 weapons
		{}, -- 3 wings
		{}, -- 4 monsters
		{}, -- 5 collects
		{} -- 6 drop
	}
end

function PoolMgr.IsExist(t, res)
	local pool = this.pool[t]
	return not this.isClear and pool and pool[res] and #pool[res] ~= 0
end

function PoolMgr.Add(t, res, callback)
	if this.isClear then callback(nil) return end
	if this.IsExist(t, res) then
		local go
		local pool = this.pool[t]
		if pool[res] == 1 then
			go = pool[res]
			if not ToLuaIsNull(go) then
				go = GameObject.Instantiate(go)
			else
				this.Create(t, res, callback, true)
			end
		else
			go = table.remove(pool[res], 1)
		end
		
		if ToLuaIsNull(go) then
			this.Add(t, res, callback)
		else
			-- activtyGameObject(go, true)
			callback(go)
		end
	else
		this.Create(t, res, callback, true)
	end
end

function PoolMgr.PreAdd(t, res)
	if this.isClear then return end
	local num = 5
	if t  == PoolMgr.MonsterType then
		num= this.poolPerTypeMax
	end
	for i=1,num do
		this.Create(t, res, nil, false)
	end
end

function PoolMgr.Create(t, res, callback, active)
	if this.isClear then callback(nil) return end
	local go = nil
	local pool = this.pool
	if t > 0 and t < #pool then
		if pool[t][res] == nil then
			pool[t][res] = {}
		end
		if t == 1 then
			LoadPlayer(res, function (o)
				if this.isClear then callback(nil) return end
				go = GameObject.Instantiate(o)
				HidePoolObj( active, go )
				if callback then callback(go) end
			end)
		elseif t == 2 then
			LoadWeapon(res, function (o)
				if this.isClear then callback(nil) return end
				go = GameObject.Instantiate(o)
				HidePoolObj( active, go )
				if callback then callback(go) end
			end)
		elseif t == 3 then
			LoadWing(res, function (o)
				if this.isClear then callback(nil) return end
				go = GameObject.Instantiate(o)
				HidePoolObj( active, go )
				if callback then callback(go) end
			end)
		elseif t == 4 then
			LoadMonster(res, function (o)
				if this.isClear then callback(nil) return end
				go = GameObject.Instantiate(o)
				HidePoolObj( active, go )
				if callback then callback(go) end
			end)
		elseif t == 5 then
			LoadCollect(res, function (o)
				if this.isClear then callback(nil) return end
				go = GameObject.Instantiate(o)
				HidePoolObj( active, go )
				if callback then callback(go) end
			end)
		elseif t == 6 then
			LoadDrop(res, function (o)
				if this.isClear then callback(nil) return end
				go = GameObject.Instantiate(o)
				HidePoolObj( active, go )
				if callback then callback(go) end
			end)
		end
	end
end

function PoolMgr.Cache(t, res, go)
	if this.isClear then return end
	if ToLuaIsNull(go) then return end
	local pool = this.pool[t]
	if not pool then
		destroyImmediate( go )
		return
	end
	if not pool[res] then
		pool[res] = {}
	end
	if #pool[res] > this.poolPerTypeMax then
		destroyImmediate( go )
		return
	end
	local comp
	comp = go:GetComponent("LuaBindSceneObj")
	if not ToLuaIsNull(comp) then
		destroy(comp)
	end
	comp = go:GetComponent("NavMeshAgent")
	if not ToLuaIsNull(comp) then
		destroy(comp)
	end
	comp = go:GetComponent("Rigidbody")
	if not ToLuaIsNull(comp) then
		destroy(comp)
	end
	comp = go:GetComponent("CapsuleCollider")
	if not ToLuaIsNull(comp) then
		destroy(comp)
	end
	comp = go:GetComponent("FS_ShadowSimple")
	if not ToLuaIsNull(comp) then
		comp.enabled = true 
	end
	HidePoolObj( false, go )
	table.insert(pool[res], go)
end

function PoolMgr.ClearAll()
	this.isClear = true
	for _,v in pairs(this.pool) do
		for _,go in pairs(v) do
			if not ToLuaIsNull(go) then 
				destroyImmediate( go )
			end
		end
	end
end

