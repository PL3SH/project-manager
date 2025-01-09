# 🏛️ Event Manager and Legislator Finder
![image](https://github.com/user-attachments/assets/17889c86-c7aa-41db-a658-8dca8f9633cd)

## 📋 Description
This project combines event management with a U.S. legislator search. It reads attendee information from a CSV, uses the Google Civic Information API to find their legislative representatives, and displays the results in a sleek, animated web interface.

## 🔧 Key Features
- Processing attendee data from a CSV file
- Automatic legislator search by postal code
- Personalized thank-you letter generation
- Modern, animated visual interface
- Responsive and professional design

## 🛠️ Technologies Used
- Ruby (data processing)
- HTML/CSS
- Google Civic Information API
- CSV parsing

## 📊 Project Structure
```project/
├── event_attendees.csv # Attendee data
├── style.css # Styles and animations
├── form_letter.erb # Letter template
└── event_manager.rb # Main script
```

## 📝 CSV Format
The `event_attendees.csv` file contains:
```csv
RegDate, first_Name, last_Name, Email_Address, HomePhone, Street, City, State, Zipcode
```

## 💻 Main Code

### CSV Reading and Legislator Search
```ruby
require 'csv'
require 'google/apis/civicinfo_v2'
def load_attendees
  CSV.open('event_attendees.csv', headers: true, header_converters: :symbol)
end
def get_legislators(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'YOUR_API_KEY'
  begin
      legislators = civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
      )
      legislators.officials
    rescue
      'Information unavailable'
  end
end
```

## 🎨 Styles and Design
The project uses a modern design defined in `style.css`:
- Fira Code font for better readability
- Smooth animations (fadeIn, slideIn, slideUp)
- Professional color scheme
- Responsive design

### Example Key Styles
```css
main.letter {
background-color: beige;
padding: 3rem;
border-radius: 12px;
box-shadow: 0 6px 12px rgba(0, 0, 0, 0.1);
width: 100%;
max-width: 800px;
text-align: center;
animation: fadeIn 1.5s ease-out;
position: relative;
}
/* Animations */
@keyframes fadeIn {
from { opacity: 0; }
to { opacity: 1; }
}
```

## 🚀 Installation

1. Clone the repository:
```bash
git clone https://github.com/your-user/your-repository.git
cd your-repository
```

2. Install dependencies:
```bash
gem install google-api-client
```

3. Set up your API key:
```ruby
config.rb
GOOGLE_API_KEY = 'your-api-key'
```

## 📖 Usage

1. Make sure the CSV file is in the correct location
2. Run the main script:
```bash
ruby event_manager.rb
```

3. The results will be displayed in the web interface and the letters will be generated in the `output/` directory.

## 🔍 Example Results
The interface will display:
- A table of legislators by state
- Contact information for representatives
- Personalized thank-you letters

## 🤝 Contributions
Contributions are welcome:

1. Fork the project
2. Create a branch (`git checkout -b feature/new-feature`)
3. Commit your changes (`git commit -am 'Add new feature'`)
4. Push to the branch (`git push origin feature/new-feature`)
5. Open a Pull Request

## 🔗 Useful Links
- [Google Civic Information API Documentation](https://developers.google.com/civic-information)
- [Ruby CSV Documentation](https://ruby-doc.org/stdlib/libdoc/csv/rdoc/CSV.html)
