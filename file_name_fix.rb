require 'pp'
require "json"

class FileNameFix

    def initialize
        @@digits = 6
    end

    # ファイル名取得
    #---------------------
    def get_file_names
        path = "./"
        file_list = Dir.entries(path)
        # 許可対象
        permission_list = [/\.jpg/i, /\.jpeg/i, /\.png/i, /\.MTS/i, /\.MP4/i, /\.MOV/i, /\.CR2/i]

        ret = []
        permission_list.each do |permission|
            ret << file_list.grep(permission)
        end

        return ret.flatten(-1)
    end

    # ファイル詳細取得(ファイル名)
    #---------------------
    def get_file_detail(file_name)
        return File.stat("./#{file_name}")
    end

    # 連番生成(生成桁数)
    #---------------------
    def get_serial_num(max_num, serial_number=0)
        num_list = [*(serial_number + 1)..(max_num + 1)]
        num_list.each_with_index do |num, i|
            num_list[i] = sprintf("%0#{@@digits}d", num)
        end
        return num_list
    end

end

last_serial_number = ""

# 同じ階層のファイル名を取得する
file_name_fix = FileNameFix.new
file_names = file_name_fix.get_file_names

data = {}
data["serial_number"] = "000000"
if File.exist?("setting.json")
  File.open("setting.json") do |f|
      data = JSON.load(f)
  end
end
serial_number  = data["serial_number"].to_i

# 実行確認
puts "#{serial_number}から開始するます。問題ないかね？(y/n)"
while true do
    answer = gets.chomp
    break  if answer == "y"
    return if answer == "n"
end

max_num = file_names.size + serial_number
serial_numbers = file_name_fix.get_serial_num(max_num, serial_number)

# 詳細情報の取得
file_names.each_with_index do |file_name, i|
    # 詳細情報の取得
    detail_data = file_name_fix.get_file_detail(file_name)

    # ファイル名変更
    raise if serial_numbers[i] == ""
    after_name = "#{serial_numbers[i]}_#{file_name}"
    File.rename(file_name, after_name)

    # フォルダ生成（フォルダが無ければ生成）
    updated_date = detail_data.mtime.strftime('%Y%m%d')
    Dir.mkdir("#{updated_date}") unless Dir.exist?("#{updated_date}")

    # ファイル移動
    File.rename("#{after_name}","#{updated_date}/#{after_name}")

    last_serial_number = serial_numbers[i]
end

# シリアル番号をsetting.jsonに書き出す
File.open('setting.json', 'w+') do |f|
    hash = {"serial_number": last_serial_number}
    JSON.dump(hash, f)
end


# はらでぃーの現代アート教室！！！
puts "👁 👁"
puts "　👃"
puts " 👄 おはよ～ #{last_serial_number}まで連番を付けたよ～！"
