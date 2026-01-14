"use client";
import React from "react";
import Link from "next/link";
import { useWishlistStore } from "@/app/_zustand/wishlistStore";
import { FaTrash } from "react-icons/fa6";

interface WishItemProps {
    id: string;
    title: string;
    price: number;
    image: string;
    slug: string;
    stockAvailabillity: number;
}

const WishItem = ({
    id,
    title,
    price,
    image,
    slug,
    stockAvailabillity,
}: WishItemProps) => {
    const { removeFromWishlist } = useWishlistStore();

    return (
        <tr className="hover:bg-gray-100 transition-colors duration-200">
            <td className="w-10">
                <label>
                    <input type="checkbox" className="checkbox checkbox-primary" />
                </label>
            </td>
            <td>
                <div className="flex items-center gap-3 justify-center">
                    <div className="avatar">
                        <div className="mask mask-squircle w-16 h-16">
                            <img src={image} alt={title} className="object-cover" />
                        </div>
                    </div>
                </div>
            </td>
            <td className="font-semibold text-lg">
                <Link href={`/product/${slug}`} className="hover:text-primary transition-colors">
                    {title}
                </Link>
            </td>
            <td>
                <div className={`badge ${stockAvailabillity > 0 ? "badge-success text-white" : "badge-error text-white"} gap-2 p-3`}>
                    {stockAvailabillity > 0 ? "In Stock" : "Out of Stock"}
                </div>
            </td>
            <td>
                <button
                    onClick={() => removeFromWishlist(id)}
                    className="btn btn-ghost btn-circle hover:bg-red-100 hover:text-red-500 transition-all duration-200"
                    title="Remove from wishlist"
                >
                    <FaTrash className="text-xl" />
                </button>
            </td>
        </tr>
    );
};

export default WishItem;
