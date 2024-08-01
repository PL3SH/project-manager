require 'csv'
require 'google/apis/civicinfo_v2'
civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'
puts "EventManager Initialized!"
#GUARDAR TODO LAS LINEAS QUE ENCUENTRE EN EL ARCHIVO EN UNA VARIABLE ESTOS DATOS SE GUARDAN EN UN ARRAY
    #    contents = File.read "event_attendees.csv"
    #MOSTRAR EL CONTENIDO DEL ARCHIVO
    #    puts contents
    #con este le decimos que lea linea por linea el archivo
    #    lines = File.readlines "event_attendees.csv"
    #con este le decimos que recorra cada linea del archivo y las muestre
    #lines.each_with_index do |line,index|
    #  next if index == 0
    #  columns = line.split(",")
    #  name = columns[2]
    #  puts name
    #end
contents = CSV.open "event_attendees.csv", headers: true, header_converters: :symbol

def clean_zipcode(zipcode)
    zipcode.to_s.rjust(5, '0')[0..4]
end
contents.each do |row|
    name = row[:first_name]
  
    zipcode = clean_zipcode(row[:zipcode])
  #puede que los datos que hayamos recojido sobre los zipcodes no sean validos al mandarse a la api por lo que con BEGIN y RESCUE se manejan los errores y no se rompre el flujo de codigo
    begin
      legislators = civic_info.representative_info_by_address(
        address: zipcode,
        levels: 'country',
        roles: ['legislatorUpperBody', 'legislatorLowerBody']
      )
      legislators = legislators.officials
    rescue
      'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
    end
  
    puts "#{name} #{zipcode} #{legislators}"
  end

