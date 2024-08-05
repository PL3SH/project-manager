# Importamos las bibliotecas necesarias
require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'
require 'date'

# Inicializamos el servicio de información cívica de Google
civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
civic_info.key = File.read('secret.key').strip

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

# Método para limpiar y formatear el código postal
def clean_zipcode(zipcode)
  # Convierte el código postal a string, rellena con ceros a la izquierda si es necesario,
  # y toma los primeros 5 caracteres
  zipcode.to_s.rjust(5, '0')[0..4]
end

# Método para obtener los legisladores por código postal
def legislators_by_zipcode(zip)
  # Inicializamos el servicio de información cívica de Google
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    # Intentamos obtener la información de los representantes
    legislators = civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    )
    legislators = legislators.officials
    # Extraemos solo los nombres de los legisladores
    legislator_names = legislators.map(&:name)
    legislator_names.join(", ")
  rescue
    # Si hay un error, devolvemos un mensaje predeterminado
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end
#begin
#If the phone number is less than 10 digits, assume that it is a bad number
#If the phone number is 10 digits, assume that it is good
#If the phone number is 11 digits and the first number is 1, trim the 1 and use the remaining 10 digits
#If the phone number is 11 digits and the first number is not 1, then it is a bad number
#If the phone number is more than 11 digits, assume that it is a bad number
#end
def save_thank_you_letter(id,form_letter)
  #creamos un directorio llamado output a menos que este ya exista
  Dir.mkdir('output') unless Dir.exist?('output')
#creamos un archivo llamado thanks_id.html en el directorio output
  filename = "output/thanks_#{id}.html"
#escribimos en el archivo gracias a la plantilla esa 'w' es para decir que vamos a modificar el archivo(write)
  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

def clean_phone_number(phone_number)
  # Verificamos que lo que nos ha llegado es una cadena
  unless phone_number.kind_of?(String)
    
    return nil
  end

  # Eliminamos cualquier carácter no numérico del número de teléfono
  phone_number = phone_number.gsub(/\D/, '')

  # Evaluamos el número de teléfono según los requisitos
  case phone_number.length
  when 10
    # Si el número de teléfono tiene 10 dígitos, es bueno
    phone_number
  when 11
    if phone_number[0] == "1"
      # Si el número de teléfono tiene 11 dígitos y empieza por 1, eliminamos el 1
      phone_number = phone_number[1..-1]
      
    else
      # Si el número de teléfono tiene 11 dígitos y no empieza por 1, es malo
    
      phone_number = nil
    end
  else
    # Si el número de teléfono tiene menos de 10 o más de 11 dígitos, es malo
    
    phone_number = nil
  end

  
end
def get_date(regdate)
  
  begin
    #convertimos el string en una fecha con horas
  date = DateTime.strptime(regdate, "%m/%d/%y %H:%M") #obtener la fecha
  rescue 
    puts "Error: #{regdate} is not a valid date"
  end
  return date
end
def frequency_hour(regdate,array)
  
  date = get_date(regdate)
  array.push(date.hour)
  return array.tally
end
def filter_peak_hours(hash)
  #guardamos los valores maximos y minimos del hash
  min_value = hash.values.min
  max_value = hash.values.max
  #eliminamos los valores que no sean mayores que el minimo y menores que el maximo para asi establecer que los valores que se queden sean los que mas se repiten
  hash.delete_if { |key, value| value <= min_value || value < max_value }
  return hash
end

def what_day(date)
  #obtenemos el dia de la semana en formato numerico (0..6) siendo 0 domingo y 6 sabado
  day = date.wday
  return day
end
def frequency_day(days)
  days = days.tally
  min_value = days.values.min
  max_value = days.values.max
  #eliminamos los valores que no sean mayores que el minimo y menores que el maximo para asi establecer que los valores que se queden sean los que mas se repiten
  days.delete_if { |key, value| value <= min_value || value < max_value }
  array_of_days = ["Lunes","Martes","Miercoles","Jueves","Viernes","Sabado","Domingo"]
  number = days.to_a.flatten.first.to_i
  
  puts "el dia mas frecuente de registracion fue el: #{array_of_days[number]}"
end
puts 'EventManager initialized.'

# Abrimos el archivo CSV con los datos de los asistentes
contents = CSV.open "../event_attendees.csv", headers: true, header_converters: :symbol

# Leemos la plantilla de la carta
template_letter = File.read('../form_letter.erb')
# Creamos un objeto ERB con la plantilla
erb_template = ERB.new template_letter
hours = []
days = []
peak_hours = 0
# Iteramos sobre cada fila del archivo CSV
contents.each do |row|
  id = row[0]
  # Extraemos el nombre del asistente
  name = row[:first_name]
  #obtenemos el numero telefonico
  phone = clean_phone_number(row[:homephone])
  # Limpiamos y formateamos el código postal
  zipcode = clean_zipcode(row[:zipcode])
  #obtenemos la fecha de registro
  date = get_date( row[:regdate])
  #obtenemos el dia de la semana
  week_day = what_day(get_date( row[:regdate]))
  #insertamos los dias de la semana en un arreglo
  days.push(week_day)
  peak_hours = frequency_hour(row[:regdate],hours)
  # Obtenemos los legisladores correspondientes al código postal
  legislators = legislators_by_zipcode(zipcode)

  # Generamos la carta personalizada usando la plantilla ERB
    form_letter = erb_template.result(binding)
  
  # Imprimimos la carta generada
  puts form_letter
  #guardamos la carta generada en un archivo
    save_thank_you_letter(id,form_letter)

end
#obtenemos la frecuecnia de las horas mediante tally
frequency_day(days)
peak_hours = filter_peak_hours(peak_hours)
puts "las horas con mas trafico son: #{peak_hours.keys}"






