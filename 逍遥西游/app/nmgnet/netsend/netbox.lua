local netbox = {}
function netbox.openNormalBox(i_free)
  NetSend({i_free = i_free}, "box", "P1")
end
function netbox.openTenNormalBox()
  NetSend({}, "box", "P2")
end
function netbox.openSuperBox(i_free)
  NetSend({i_free = i_free}, "box", "P3")
end
function netbox.openTenSuperBox()
  NetSend({}, "box", "P4")
end
function netbox.askBoxState()
  NetSend({}, "box", "P5")
end
return netbox
