function OnLButtonDown(self)
	local bkg = self:GetControlObject("button.bkg")
	local attr = self:GetAttribute()
	
	bkg:SetTextureID(attr.DownBkg or "")

	local backimage = self:GetControlObject("button.img")
	backimage:SetResID(attr.ImageDown or attr.Image or "")
end

function OnLButtonUp(self)
	local attr = self:GetAttribute()
	
	local bkg = self:GetControlObject("button.bkg")
	bkg:SetTextureID(attr.NormalBkg or "")
	
	local backimage = self:GetControlObject("button.img")
	backimage:SetResID(attr.Image or "")
	
	self:FireExtEvent("OnClick")
end

function OnMouseEnter(self)
	local attr = self:GetAttribute()
	
	local bkg = self:GetControlObject("button.bkg")
	bkg:SetTextureID(attr.HoverBkg or "")
	
	local backimage = self:GetControlObject("button.img")
	backimage:SetResID(attr.ImageHover or attr.Image or "")
	
end

function OnInitControl(self)
	local attr = self:GetAttribute()
	
	local bkg = self:GetControlObject("button.bkg")
	bkg:SetTextureID(attr.NormalBkg or "")
	
	local backimage = self:GetControlObject("button.img")
	backimage:SetResID(attr.Image or "")
end

function OnMouseLeave(self)
	local attr = self:GetAttribute()
	
	local bkg = self:GetControlObject("button.bkg")
	bkg:SetTextureID(attr.NormalBkg or "")
	
	local backimage = self:GetControlObject("button.img")
	backimage:SetResID(attr.Image or "")
end