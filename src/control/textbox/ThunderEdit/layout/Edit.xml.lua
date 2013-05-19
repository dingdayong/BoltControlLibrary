function SetText(self, text)
	local edit = self:GetControlObject("edit.content")
	edit:SetText(text)
end

function GetText(self)
	local edit = self:GetControlObject("edit.content")
	return edit:GetText()
end



function OnInitControl(self)
	DEBUG("OnInitControl  " .. tostring(self))	
	local root= self
	local bkg = root:GetControlObject("edit.border")
	local attr = root:GetAttribute()	
	bkg:SetTextureID(attr.NormalBkg or "")
	
	local editObject = root:GetControlObject("edit.content")
	editObject:SetText(attr.value or "")
end

function OnMouseEnter(self)
	DEBUG("OnMouseEnter  " .. tostring(self))

	-- local root=self
	-- local bkg = root:GetControlObject("edit.border")
	-- local attr = root:GetAttribute()	
	-- bkg:SetTextureID(attr.HoverBkg or "")
end

function OnMouseLeave(self)
	DEBUG("OnMouseLeave  " .. tostring(self))

	-- local root=self
	-- local bkg = root:GetControlObject("edit.border")
	-- local attr = root:GetAttribute()
	-- if not root:GetFocus() then
	-- 	bkg:SetTextureID(attr.HoverBkg or "")
	-- else 
	-- 	bkg:SetTextureID(attr.NormalBkg or "")
	-- 	DEBUG("OnMouseLeave  : false")
	-- end
end

function OnFocusChange( self, status )
	DEBUG("OnFocusChange  " .. tostring(self) .. "  " .. tostring(status))
	local root=self
	if status then
		local edit = root:GetControlObject("edit.content")
		edit:SetFocus( true )
		
		local bkg = root:GetControlObject("edit.border")
		local attr = root:GetAttribute()	
		bkg:SetTextureID(attr.HoverBkg or "")
	else 
		local edit = root:GetControlObject("edit.content")
		edit:SetFocus( false )
		
		local bkg = root:GetControlObject("edit.border")
		local attr = root:GetAttribute()	
		bkg:SetTextureID(attr.NormalBkg or "")		
	end
end


function DEBUG(msg)
	XLPrint("UELoader:" .. msg)
end
