require 'date'
require 'holidays'
require 'prawn'
require 'awesome_print'
def is_holiday?(date)
	(HHolidays.on(date, :us).len) ? true : false
end
# Letter size = 612pt bounds.width (8/5"), 792pt bounds.height
def dump(s)
	ap s; exit
end
def rColLeft
	mid + 36
end
def mid
		(bounds.width - 5) / 2
end
def weekRule

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
	b = (date.cwday > 5) ? "0000FF" : "000000"
	fill_color b 
	z = %w(U M T W R F S U)
	holiday = ""
	if Holidays.on(date, :us).size > 0
		holiday = Holidays.on(date, :us).first[:name]
		fill_color "FF0000"
	end
	draw_text date.strftime("#{z[date.cwday]} %d %b #{holiday}"), :at => [s + 3, h - 12]
end
def resetStroke
	stroke_color "EEEEEE"
end
def drawGrid(h,r,s,w)
	dash(1, :space => r, :phase => 0)
	stroke_color "888888"
	stroke_horizontal_line s, w, :at => h			
	undash
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
		stroke_horizontal_line s, w, :at => h
		drawGrid(h,r,s,w)  unless dates.is_a? Array
		h -= r
	end
end
def drawMargins
	dash(2, :space => 7, :phase => 7)
	resetStroke
	# stroke_horizontal_line bounds.left, bounds.width, :at => bounds.bottom
	# stroke_horizontal_line bounds.left, bounds.width, :at => bounds.height
	stroke_vertical_line   bounds.left, bounds.height, :at => bounds.top_left
	stroke_vertical_line   bounds.left, bounds.height, :at => bounds.width 
	stroke_vertical_line bounds.left, bounds.height, :at => mid - 54
	stroke_vertical_line bounds.left, bounds.height, :at => mid + 36
	stroke_vertical_line 0, bounds.height + 36, :at => mid
	undash()
end

def junior
	dash(3, :space => 7, :phase => 7)
end
def dotrule(at,width)
	return stroke_axis(
		:at => at,
		:width => width,
		:height => cursor.to_i - 140,
	 	:step_length => 20,
		:negative_axes_length => 40,
		:color => 'FF00'
	)
end

# raise Date.today.at_beginning_of_month.inspect
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

Prawn::Document.generate(
	"builds/weekly.pdf",
	:margin => [18,18,18,18],
	:page_layout => :landscape
) do

offset = 0
	@today = Date.today
	@fom   = Date.new(@today.year,@today.mon + offset,1)
	@eom   = Date.new(@today.year,@today.mon + offset,-1)

	# Set the Month Calendar View
  @month = getDays(@fom,@eom.day)
	wideRule(30)
  wideRule(@eom.day, 0, mid - 54, @month)
  start_new_page

	# Set the weekly calendars
	fom = @fom
	5.times do 
		@week = getDays(fom,7)
		drawMargins
		wideRule(30)
		wideRule(7, 0, mid - 54, @week)
		start_new_page
		fom += 7
	end
end