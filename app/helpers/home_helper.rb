module HomeHelper
  def number_of_week_in_thu
    #for term from 2011.02.21 to 2011.??.??
    base = Date.parse('2011-02-21')
    if Date.today >= base && Date.today < base + 16 * 7
      "第#{((Date.today - base) / 7).to_i + 1}周"
    else
      ''
    end
  end
end
