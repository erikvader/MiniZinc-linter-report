#!/bin/python

import csv

def read():
    with open("counts_base.csv", "r") as f:
        reader = csv.DictReader(f, delimiter=',')
        return [row for row in reader]

def save(counts):
    with open("counts.csv", "w") as f:
        writer = csv.DictWriter(f, ["numnodes", "occur", "cum", "perc"], delimiter=',')
        writer.writeheader()
        for c in counts:
            writer.writerow(c)

def main():
    counts = read()
    cum = 0
    for c in counts:
        cum += int(c["occur"])
        c["cum"] = cum

    for c in counts:
        c["perc"] = int(c["cum"]) / cum

    save(counts)

if __name__ == "__main__":
    main()
