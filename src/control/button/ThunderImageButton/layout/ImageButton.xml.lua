function OnLButtonDown(self)
	local bkg = self:GetControlObject("button.bkg")
	local attr = self:GetAttribute()
	
	bkg:SetResID(attr.DownBkg)
	RemoveTip( self )
end

function OnLButtonUp(self)
	local bkg = self:GetControlObject("button.bkg")
	local attr = self:GetAttribute()
	
	bkg:SetResID(attr.NormalBkg)
	
	self:FireExtEvent("OnClick")
end

function OnMouseHover( self, x, y )
	AddTip(self, x, y)
	return 0
end

function OnMouseEnter(self)
	local bkg = self:GetControlObject("button.bkg")
	local attr = self:GetAttribute()
	
	bkg:SetResID(attr.HoverBkg)
end

function OnMouseLeave(self)
	local bkg = self:GetControlObject("button.bkg")
	local attr = self:GetAttribute()
	
	bkg:SetResID(attr.NormalBkg)
	RemoveTip( self )
end

function OnPosChange(self, focus)
	if not focus then
		RemoveTip(self)
	end
	return true
end

function OnInitControl(self)
	local bkg = self:GetControlObject("button.bkg")
	local attr = self:GetAttribute()
	
	bkg:SetResID(attr.NormalBkg)
end

function RemoveTip(self)
	local attr = self:GetAttribute()
	local tipObj = attr.TipObj
	if tipObj ~= nil then
		self:RemoveChild(tipObj)
		attr.TipObj = nil
	end
end

function AddTip(self, x, y)

end

function AddTipText(self,newText)
	local attr = self:GetAttribute()
	if attr then
		attr.TipText = newText
	end
end

function GetTipText(self)
    local attr = self:GetAttribute()
    return attr.TipText
end

