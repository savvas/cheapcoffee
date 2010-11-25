class SuggestedPrice < ActiveRecord::Base
    belongs_to :cafeteria
    belongs_to :user

    after_create :update_cafeteria

    def update_cafeteria
        total = SuggestedPrice.where(:cafeteria_id=>self.cafeteria_id).where(:product=>self.product).where(:price=>self.price).count
        cafeteria = self.cafeteria
        votes_field = "votes_#{self.product.split("_")[1]}"
        if cafeteria.send(votes_field).to_f < total.to_f
            cafeteria.send(votes_field+"=",total)
            cafeteria.send("#{self.product}=", self.price)
            cafeteria.save
        end
    end

end

