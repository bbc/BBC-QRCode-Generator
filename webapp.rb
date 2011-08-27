class BBCQRCode < Sinatra::Base
  set :run, false

  # expects bitly credentials to live in ~/.bitlyrc
  BITLY = YAML::load(File.read(File.expand_path('~')+'/.bitlyrc'))
  BBC_LOGO = [
    ['w',  7, 15, 31, 23], ['b',  8, 16, 14, 22],
    ['b', 16, 16, 22, 22], ['b', 24, 16, 30, 22],
    ['w', 10, 17, 12, 21], ['w', 18, 17, 20, 21],
    ['b', 12, 17], ['b', 11, 18], ['b', 12, 19], 
    ['b', 11, 20], ['b', 12, 21], ['b', 20, 17],
    ['b', 19, 18], ['b', 20, 19], ['b', 19, 20], 
    ['b', 20, 21], ['w', 27, 17, 28, 17], 
    ['w', 26, 18, 26, 20], ['w', 27, 21, 28, 21]
  ]

  helpers do 
    def build_bbc_logo
      logo = Magick::Draw.new
      BBC_LOGO.each do |i|
        col = i.first == 'w' ? 'white' : 'black'
        logo.fill(col)
        if i.size < 4
          logo.point(i[1],i[2])
        else
          logo.rectangle(i[1],i[2],i[3],i[4])
        end
      end
      logo 
    end

    def build_qrcode(url, border=1)
      qr = RQRCode::QRCode.new(url, :size => 5)
      qrcode = Magick::Draw.new
      qr.modules.each_index do |x|
        qr.modules.each_index do |y|
          qrcode.fill( qr.dark?(x,y) ? 'black' : 'white' )
          qrcode.point(y+border,x+border)
        end
      end
      qrcode
    end

    def shorten(url)
      Bitly.use_api_version_3
      bitly = Bitly.new(BITLY[:username], BITLY[:api_key])
      bitly.shorten(url).short_url
    end
  end

  get '/:width' do
    content_type 'image/png'

    unless shorten(params[:url]).match(/http:\/\/bbc\.in/)
      halt 400, {'Content-Type' => 'text/plain'}, 'Oops! I will only encode BBC urls'
    end

    img = Magick::Image.new(39,39)
    build_qrcode(url).draw(img)
    build_bbc_logo.draw(img)
    size = params[:width].to_i
    img.resize(size,size,Magick::PointFilter).to_blob { 
      self.format = 'PNG'
    } 
  end
end

