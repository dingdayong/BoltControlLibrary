function SetCaption(self, text)
    local attr = self:GetAttribute()
    attr.caption = text
    local textObj = self:GetControlObject("mainwnd.title")
    textObj:SetText(text)
    if text and text ~= "" then
	textObj:SetVisible(true)
    else
	textObj:SetVisible(false)
    end
end

function SetBkg(self, bkg)
    local attr = self:GetAttribute()
    attr.bkg = bkg
    local bkg = self:GetControlObject("mainwnd.bkg")
    bkg:SetTextureID (attr.bkg)
end

function GetCaption(self)
	local textObj = self:GetControlObject("mainwnd.title")
	return textObj:GetText()
end

function UpdateUI(self)
    local attr = self:GetAttribute()
   
    local bkg = self:GetControlObject("mainwnd.bkg")
    bkg:SetTextureID (attr.bkg)
    
    local cap = self:GetControlObject("mainwnd.header")
    cap:SetObjPos(0,0, "father.width", attr.captionheight)
    

    local text = self:GetControlObject("mainwnd.title")
    text:SetText(attr.Caption)
    if attr.captioncolor then
		text:SetTextColor(attr.captioncolor)
	end
end

function OnInitControl(self)
    UpdateUI(self)
end

function OnUpdateStyle(self)
    UpdateUI(self)
end