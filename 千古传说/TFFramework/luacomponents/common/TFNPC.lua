TFNPC = class("TFNPC", function ( ... )
	return TFImage:create(...)
end)

function TFNPC:create( ... )
	return TFNPC:new(...)
end

function TFNPC:getEditorDescription()
	return "TFNPC"
end

return TFNPC