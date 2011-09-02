require 'base64'
require 'cgi'

class BBCQRCode < Sinatra::Base
  set :run, false
  set :static, true
  set :public, 'public'
  set :root, File.dirname(__FILE__)

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
  DEFAULT_SIZE=400

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
    rescue SocketError
      nil
    end

    def is_bbc?(url)
      # doesn't match bbc subdomains
      url.match(/^https?:\/\/([-\w\.]+)?(bbc\.co\.uk|bbc\.in)/)
    end

    def to_qrcode_blob(code,size)
      size = (size > 800 || size < 39) ? size = DEFAULT_SIZE : size
      img = Magick::Image.new(39,39)
      build_qrcode('http://bbc.in/'+code).draw(img)
      build_bbc_logo.draw(img)
      blob = img.resize(size,size,Magick::PointFilter).to_blob { 
        self.format = 'PNG'
      } 
      blob
    end

    def to_qrcode_base64(blob)
      "data:image/png;base64,#{Base64.encode64(blob)}"
    end

    def qrcode_url(slug,size=DEFAULT_SIZE)
      "/qrcodes/#{size}/#{slug}"
    end
  end

  before do
    response["Cache-Control"] = "max-age=31556926, public"
  end

  get '/' do
    @validate = true
    erb :index
  end

  post '/generate' do
    halt 400, 
      "Invalid! You can only encode BBC urls. Go back and try again." unless is_bbc?(params[:url])

    destination = "/qrcodes/#{DEFAULT_SIZE}/#{Base64.urlsafe_encode64(params[:url])}"
    redirect to destination
  end

  get '/qrcodes/:size/*' do
    begin
      slug = params[:splat].first
      url = Base64.urlsafe_decode64(slug)
    rescue ArgumentError
      return redirect to '/'
    end

    halt 400, "Invalid! You can only encode BBC urls. Go back and try again." unless is_bbc?(url)
    
    short = shorten(url)
    halt 400, "Error! I can't connect to bit.ly" unless short

    code = short.split('/').last
    size = params[:size] ? params[:size].to_i : 0
    @qrcode = {
      :original_url => url,
      :short_url => short, 
      :code => code,
      :slug => slug,
      :blob => to_qrcode_blob(code, size)
    }
    erb :qrcodes
  end
end
