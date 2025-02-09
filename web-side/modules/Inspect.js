
class Inspect extends Inventory{
    
    constructor(data, side = "right"){
        super(data, side);
        const {target_name} = data
        $(".inventory-right-type").text(`${target_name}`);
    }
    async takeItem(from_slot, amount, to_slot){
        if(typeof from_slot == "number") from_slot = from_slot.toString();
        if(typeof to_slot == "number") to_slot = to_slot.toString();
        let invInstance = window.classInstances["left"];
        amount = ((amount > this.items[from_slot].amount || amount <= 0) ? this.items[from_slot].amount : amount);
        if(invInstance.items[to_slot]){
            if(invInstance.items[to_slot].item == this.items[from_slot].item){
                const response = await Client("TAKE_INSPECT_ITEM", {
                    amount,
                    from_slot,
                    to_slot
                })
                if(typeof response !== "boolean" && response?.error){
                    Notify(response.error,"error");
                    invInstance.renderSlots("left");
                    this.renderSlots("right");
                    return
                }
                invInstance.items[to_slot].amount += amount;
                this.items[from_slot].amount -= amount;
                if(this.items[from_slot].amount <= 0){
                    delete this.items[from_slot];
                }
                invInstance.renderSlots("left");
                this.renderSlots("right");

                return true;
            }
        }else{
            const response = await Client("TAKE_INSPECT_ITEM", {
                amount,
                from_slot,
                to_slot
            })
            if(typeof response !== "boolean" && response?.error){
                Notify(response.error,"error");
                invInstance.renderSlots("left");
                this.renderSlots("right");
                return
            }
            if(amount >= this.items[from_slot].amount){
                invInstance.items[to_slot] = JSON.parse(JSON.stringify(this.items[from_slot]));
                delete this.items[from_slot];
                invInstance.renderSlots("left");
                this.renderSlots("right");
                return true;
            }else{
                invInstance.items[to_slot] = JSON.parse(JSON.stringify(this.items[from_slot]));
                invInstance.items[to_slot].amount = amount;
                this.items[from_slot].amount -= amount;
                invInstance.renderSlots("left");
                this.renderSlots("right");
                return true;
            }
        }
    }


    async putItem(from_slot, amount, to_slot){
        if(typeof from_slot == "number") from_slot = from_slot.toString();
        if(typeof to_slot == "number") to_slot = to_slot.toString();
        let invInstance = window.classInstances["left"];
        amount = ((amount > invInstance.items[from_slot].amount || amount <= 0) ? invInstance.items[from_slot].amount : amount);
        
        if(invInstance.items[from_slot] && this.items[to_slot]){
            if(invInstance.items[from_slot].item == this.items[to_slot].item){
                console.log("Os itens são do mesmo tipo!")
                const response = await Client("PUT_INSPECT_ITEM", {
                    amount,
                    from_slot,
                    to_slot
                })
                if(typeof response !== "boolean" && response?.error){
                    Notify(response.error,"error")
                    invInstance.renderSlots("left");
                    this.renderSlots("right");
                    return
                }
                if(!response){
                    return false;
                }
                invInstance.items[from_slot].amount -= amount;
                if(invInstance.items[from_slot].amount <= 0){
                    delete invInstance.items[from_slot];
                }
                this.items[to_slot].amount += amount;
                this.renderSlots("right");
                invInstance.renderSlots("left");
                console.log("Movimentação realizada com sucesso!")
                return true;
            }else{
                console.log("Os itens não são do mesmo tipo!")
                invInstance.renderSlots("left");
                this.renderSlots("right");
                return false;
            }
        }


        if(invInstance.items[from_slot] && !this.items[to_slot]){
            const response = await Client("PUT_INSPECT_ITEM", {
                amount,
                from_slot,
                to_slot
            })
            if(typeof response !== "boolean" && response?.error){
                Notify(response.error,"error")
                invInstance.renderSlots("left");
                this.renderSlots("right");
                return
            }
            if(!response){
                invInstance.renderSlots("left");
                this.renderSlots("right");
                return false;
            }
            if(amount >= invInstance.items[from_slot].amount){
                console.log("deletando!")
                this.items[to_slot] = JSON.parse(JSON.stringify(invInstance.items[from_slot]));
                delete invInstance.items[from_slot];
                invInstance.renderSlots("left");
                this.renderSlots("right");
                return true;
            }else{
                invInstance.items[from_slot].amount -= amount;
                this.items[to_slot] = JSON.parse(JSON.stringify(invInstance.items[from_slot]));
                this.items[to_slot].amount = amount;
                invInstance.renderSlots("left");
                this.renderSlots("right");
                return true;
            }
        }
        invInstance.renderSlots("left")
        this.renderSlots("right")
        return false 
    }
}