require 'date'
require 'holidays'
require 'prawn'
require 'awesome_print'
def is_holiday?(date)
	(Holidays.on(date, :us).size > 0) ? true : false
end
# Letter size = 612pt bounds.width (8/5"), 792pt bounds.height
def dump(s)
	ap s; exit
end
# def rxColLeft
# 	mid + 36
# end
def mid
		(bounds.width - 5) / 2
end
def drawWeekDate(date, s, h, j)
	fill_color "000000" 
	draw_text date.strftime("%A, %-d %B"), :at => [s + 3, h - 12]
	fill_color "CCCCCC" 
	x = (j == 0) ? ["(%W, %0j)",280] : ["    (%0j)",286]
	draw_text date.strftime(x[0]), :at => [s + x[1], h - 12]
	fill_color "000000" 
end
def drawMonthDate(date, s, h, j)
	fill_color case
		when is_holiday?(date)
			"FF0000"
		when date.cwday > 5
			"0000FF"
		else
			"000000"
	end
	if is_holiday?(date)
		holiday = Holidays.on(date, :us).first[:name]
		draw_text date.strftime(holiday),
				:at => [320 - width_of(holiday), h - 14],
				:size => 10,
				:font => 'DroidSans'
	end
	draw_text date.strftime("#{%w(U M T W R F S U)[date.cwday]}"),
			:at => [s + 8,  h - 14],
			:size => 7,
			:font => 'DroidSansMono'

	draw_text date.strftime("%_d %b"),
			:at => [s + 16, h - 14],
			:size => 10,
			:font => 'DroidSansMono'

	font 'DroidSans'
end
def resetStroke
	stroke_color "EEEEEE"
end
def drawGrid(h,r,s,w)
	dash(1, :space => r, :phase => 0)
	stroke_color "888888"
	stroke_horizontal_line s, w, :at => h			
	undash
	resetStroke
end
def wideRule(i=30, s=nil,w=nil,dates=nil)

	s = mid + 36 if s.nil?
	w = bounds.width if w.nil?
	h = bounds.top
	r = bounds.height / i
	
	(i+1).times do |j|
		if dates.is_a? Array
			font_size 10
			date = dates[j]
			unless date.nil?
				drawWeekDate(date, s, h, j)  if i == 7
				drawMonthDate(date, s, h, j) if i >27
			end
		end
		resetStroke
		stroke_horizontal_line s, w, :at => h unless (dates.is_a? Array and i > 27 and j == 0)
		drawGrid(h,r,s,w)  unless dates.is_a? Array
		h -= r
	end
end
def drawMidline
	stroke_color "888888"
	dash(4, :space => 7, :phase => 0)
	stroke_vertical_line -36, bounds.height + 36, :at => mid
	undash()
	resetStroke
end
def drawMargins
	dash(4, :space => 7, :phase => 0)
	
	resetStroke
	stroke_horizontal_line bounds.left, bounds.width, :at => bounds.bottom
	stroke_horizontal_line bounds.left, bounds.width, :at => bounds.height
	stroke_vertical_line   bounds.left, bounds.height, :at => bounds.top_left
	stroke_vertical_line   bounds.left, bounds.height, :at => bounds.width 
	stroke_vertical_line   bounds.left, bounds.height, :at => mid - 54
	stroke_vertical_line   bounds.left, bounds.height, :at => mid + 36
	stroke_vertical_line   0, bounds.height + 36, :at => mid
	undash()
	
end

def junior
	dash(3, :space => 7, :phase => 7)
end

def getDays(fom,i)
	fomw = fom
	fom -= (fom.cwday + 1) if i == 7
	
	days = []
	i.times do
		days << fomw
		fomw += 1
	end
	days
end
def drawMonthTitle(date)
	draw_text date.strftime("%B %Y"), :at => [0,bounds.height / 2], :rotate => 90, :size => 16
end

def setFont
	font_families.update(
		"DroidSansMono" => {
		  :normal => "fonts/Droid_Sans_Mono/DroidSansMono.ttf"
		},
		"DroidSans" => {
		  :normal => "fonts/Droid_Sans/DroidSans.ttf"
		}
	)
end

Prawn::Document.generate(
	"builds/weekly.pdf",
	:margin => [18,18,18,18],
	:page_layout => :landscape
) do
	setFont
	offset = 0
	@today = Date.today
	@fom   = Date.new(@today.year,@today.mon + offset,1)
	@eom   = Date.new(@today.year,@today.mon + offset,-1)

	# Set the Month Calendar View
	
	drawMonthTitle(@today)
	
  @month = getDays(@fom,@eom.day)
	wideRule(30)
  wideRule(@eom.day, 0, mid - 54, @month)
  drawMidline
  start_new_page

	# Set the weekly calendars
	fom = @fom
	5.times do 
		@week = getDays(fom,7)
		drawMidline
		# drawMargins
		wideRule(30)
		wideRule(7, 0, mid - 54, @week)
		start_new_page
		fom += 7
	end
end