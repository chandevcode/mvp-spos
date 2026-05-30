require "test_helper"

class CartControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @product = products(:one)
    sign_in @user
  end

  test "should get show" do
    get cart_url
    assert_response :success
  end

  test "should add to cart" do
    post add_to_cart_url(@product)
    assert_redirected_to root_path
    assert_equal "Added to cart", flash[:notice]
    assert_equal 1, session[:cart][@product.id.to_s]
  end

  test "should remove from cart" do
    post add_to_cart_url(@product)
    post remove_from_cart_url(@product)
    assert_redirected_to root_path
    assert_nil session[:cart][@product.id.to_s]
  end

  test "should clear cart" do
    post add_to_cart_url(@product)
    delete clear_cart_url
    assert_empty session[:cart]
    assert_redirected_to root_path
    assert_equal "Cart cleared", flash[:notice]
  end

  test "should checkout and redirect to transaction when print is true" do
    post add_to_cart_url(@product)
    
    assert_difference "Transaction.count", 1 do
      post checkout_url(print: true)
    end
    
    transaction = Transaction.last
    assert_redirected_to transaction_path(transaction)
    assert_equal "Order completed successfully!", flash[:notice]
    assert_empty session[:cart]
  end

  test "should checkout and redirect to root when print is false" do
    post add_to_cart_url(@product)
    
    assert_difference "Transaction.count", 1 do
      post checkout_url
    end
    
    assert_redirected_to root_path
    assert_equal "Order completed successfully!", flash[:notice]
    assert_empty session[:cart]
  end
end
