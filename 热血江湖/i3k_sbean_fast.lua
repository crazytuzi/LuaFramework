
-- 解包效率优化
-- 这个文件中优化的bean有改动的时候需要手工修改这个文件

function i3k_sbean.nearby_move_monster.fastDecode(v)
	local tbl = { }
	local p = 1
	p = p + 1
	p = p + 1
	tbl.id = tonumber(v[p])
	p = p + 2
	tbl.pos = { x = tonumber(v[p]), y = tonumber(v[p+1]), z = tonumber(v[p+2]) }
	p = p + 3
	tbl.speed = tonumber(v[p])
	p = p + 2
	tbl.rotation = { x = tonumber(v[p]), y = tonumber(v[p+1]), z = tonumber(v[p+2]) }
	p = p + 4
	tbl.target = { x = tonumber(v[p]), y = tonumber(v[p+1]), z = tonumber(v[p+2]) }
	p = p + 4
	tbl.timeTick = { tickLine = tonumber(v[p]), outTick = tonumber(v[p+1]) }
	return tbl
end