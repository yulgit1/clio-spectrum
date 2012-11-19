require 'spec_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

describe ItemAlertsController do

  # This should return the minimal set of attributes required to create a valid
  # ItemAlert. As you add validations to ItemAlert, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {}
  end

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # ItemAlertsController. Be sure to keep this updated too.
  def valid_session
    {}
  end

  describe "GET index" do
    it "assigns all item_alerts as @item_alerts" do
      item_alert = ItemAlert.create! valid_attributes
      get :index, {}, valid_session
      assigns(:item_alerts).should eq([item_alert])
    end
  end

  describe "GET show" do
    it "assigns the requested item_alert as @item_alert" do
      item_alert = ItemAlert.create! valid_attributes
      get :show, {:id => item_alert.to_param}, valid_session
      assigns(:item_alert).should eq(item_alert)
    end
  end

  describe "GET new" do
    it "assigns a new item_alert as @item_alert" do
      get :new, {}, valid_session
      assigns(:item_alert).should be_a_new(ItemAlert)
    end
  end

  describe "GET edit" do
    it "assigns the requested item_alert as @item_alert" do
      item_alert = ItemAlert.create! valid_attributes
      get :edit, {:id => item_alert.to_param}, valid_session
      assigns(:item_alert).should eq(item_alert)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new ItemAlert" do
        expect {
          post :create, {:item_alert => valid_attributes}, valid_session
        }.to change(ItemAlert, :count).by(1)
      end

      it "assigns a newly created item_alert as @item_alert" do
        post :create, {:item_alert => valid_attributes}, valid_session
        assigns(:item_alert).should be_a(ItemAlert)
        assigns(:item_alert).should be_persisted
      end

      it "redirects to the created item_alert" do
        post :create, {:item_alert => valid_attributes}, valid_session
        response.should redirect_to(ItemAlert.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved item_alert as @item_alert" do
        # Trigger the behavior that occurs when invalid params are submitted
        ItemAlert.any_instance.stub(:save).and_return(false)
        post :create, {:item_alert => {}}, valid_session
        assigns(:item_alert).should be_a_new(ItemAlert)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        ItemAlert.any_instance.stub(:save).and_return(false)
        post :create, {:item_alert => {}}, valid_session
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested item_alert" do
        item_alert = ItemAlert.create! valid_attributes
        # Assuming there are no other item_alerts in the database, this
        # specifies that the ItemAlert created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        ItemAlert.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, {:id => item_alert.to_param, :item_alert => {'these' => 'params'}}, valid_session
      end

      it "assigns the requested item_alert as @item_alert" do
        item_alert = ItemAlert.create! valid_attributes
        put :update, {:id => item_alert.to_param, :item_alert => valid_attributes}, valid_session
        assigns(:item_alert).should eq(item_alert)
      end

      it "redirects to the item_alert" do
        item_alert = ItemAlert.create! valid_attributes
        put :update, {:id => item_alert.to_param, :item_alert => valid_attributes}, valid_session
        response.should redirect_to(item_alert)
      end
    end

    describe "with invalid params" do
      it "assigns the item_alert as @item_alert" do
        item_alert = ItemAlert.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        ItemAlert.any_instance.stub(:save).and_return(false)
        put :update, {:id => item_alert.to_param, :item_alert => {}}, valid_session
        assigns(:item_alert).should eq(item_alert)
      end

      it "re-renders the 'edit' template" do
        item_alert = ItemAlert.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        ItemAlert.any_instance.stub(:save).and_return(false)
        put :update, {:id => item_alert.to_param, :item_alert => {}}, valid_session
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested item_alert" do
      item_alert = ItemAlert.create! valid_attributes
      expect {
        delete :destroy, {:id => item_alert.to_param}, valid_session
      }.to change(ItemAlert, :count).by(-1)
    end

    it "redirects to the item_alerts list" do
      item_alert = ItemAlert.create! valid_attributes
      delete :destroy, {:id => item_alert.to_param}, valid_session
      response.should redirect_to(item_alerts_url)
    end
  end

end