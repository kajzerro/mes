/**
 * ********************************************************************
 * Code developed by amazing QCADOO developers team.
 * Copyright (c) Qcadoo Limited sp. z o.o. (2010)
 * ********************************************************************
 */

package com.qcadoo.mes.beans.products;

import java.util.List;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.ManyToOne;
import javax.persistence.OneToMany;
import javax.persistence.Table;

import org.hibernate.annotations.Cascade;
import org.hibernate.annotations.CascadeType;

@Entity
@Table(name = "products_instruction")
public class ProductsInstruction {

    @Id
    @GeneratedValue
    private Long id;

    @Column(nullable = false, length = 40)
    private String number;

    @Column(nullable = false)
    private String name;

    @ManyToOne(fetch = FetchType.EAGER)
    private ProductsProduct product;

    @Column
    private String description;

    private Boolean master;

    @OneToMany(mappedBy = "instruction", fetch = FetchType.LAZY)
    @Cascade({ CascadeType.DELETE })
    private List<ProductsInstructionBomComponent> bomComponents;

    @OneToMany(mappedBy = "instruction", fetch = FetchType.LAZY)
    private List<ProductsOrder> orders;

    public Long getId() {
        return id;
    }

    public void setId(final Long id) {
        this.id = id;
    }

    public String getNumber() {
        return number;
    }

    public void setNumber(final String number) {
        this.number = number;
    }

    public String getName() {
        return name;
    }

    public void setName(final String name) {
        this.name = name;
    }

    public ProductsProduct getProduct() {
        return product;
    }

    public void setProduct(final ProductsProduct product) {
        this.product = product;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(final String description) {
        this.description = description;
    }

    public Boolean getMaster() {
        return master;
    }

    public void setMaster(final Boolean master) {
        this.master = master;
    }

    public List<ProductsInstructionBomComponent> getBomComponents() {
        return bomComponents;
    }

    public void setBomComponents(final List<ProductsInstructionBomComponent> bomComponents) {
        this.bomComponents = bomComponents;
    }

    public List<ProductsOrder> getOrders() {
        return orders;
    }

    public void setOrders(final List<ProductsOrder> orders) {
        this.orders = orders;
    }

}
