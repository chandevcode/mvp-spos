namespace :verify do
  task storage: :environment do
    begin
      # Find first product
      product = Product.first
      if product.nil?
        puts "❌ No products found to attach to."
        next
      end
      
      puts "Testing Active Storage attachment for product: #{product.id}"
      
      # Create a dummy attachment
      product.image.attach(io: StringIO.new("test content"), filename: "test.txt", content_type: "text/plain")
      
      if product.image.attached?
        puts "✅ Attachment created successfully in DB."
        # Use Active Storage service to check existence in R2
        if product.image.blob.service.exist?(product.image.blob.key)
          puts "✅ File confirmed to exist in R2 service."
        else
          puts "❌ File NOT found in R2 service."
        end
      else
        puts "❌ Attachment failed."
      end
    rescue => e
      puts "❌ Error testing storage: #{e.message}"
      puts e.backtrace.join("\n")
    end
  end
end
